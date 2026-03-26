use chrono::Local;
use eframe::egui;
use rand::seq::SliceRandom;
use std::collections::HashSet;
use std::fs;
use std::io::Write;
use std::path::PathBuf;

// ── File paths (resolved from $HOME so the app works when launched from anywhere) ──

fn data_path(filename: &str) -> PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
    PathBuf::from(home).join(filename)
}

fn list_file() -> PathBuf { data_path("names.txt") }
fn backup_file() -> PathBuf { data_path("names_backup.txt") }
fn log_file() -> PathBuf { data_path("vto_log.txt") }

// ── Helpers ───────────────────────────────────────────────────────────────────

fn log_entry(message: &str) {
    if let Ok(mut f) = fs::OpenOptions::new().create(true).append(true).open(log_file()) {
        let _ = writeln!(f, "{}", message);
    }
}

fn load_names(path: &PathBuf) -> Vec<String> {
    fs::read_to_string(path)
        .unwrap_or_default()
        .lines()
        .map(|l| l.trim().to_string())
        .filter(|l| !l.is_empty())
        .collect()
}

fn save_names(names: &[String], path: &PathBuf) {
    let _ = fs::write(path, names.join("\n"));
}

// Used by the auto-refresh mid-session (no merging needed there).
fn restore_from_backup() -> Vec<String> {
    let names = load_names(&backup_file());
    save_names(&names, &list_file());
    names
}

// Used by manual resets: restores the full backup but keeps any names that
// were added to the active list after the backup was created.
fn reset_preserving_new_names() -> Vec<String> {
    let backup = load_names(&backup_file());
    let current = load_names(&list_file());
    let backup_set: HashSet<String> = backup.iter().cloned().collect();
    let mut merged = backup;
    for name in current {
        if !backup_set.contains(&name) {
            merged.push(name);
        }
    }
    // Persist merged list as the new backup so future resets also include the new names.
    save_names(&merged, &backup_file());
    save_names(&merged, &list_file());
    merged
}

fn today_str() -> String {
    Local::now().format("%B %d, %Y").to_string()
}

// ── State types ───────────────────────────────────────────────────────────────

#[derive(PartialEq, Clone, Copy)]
enum Screen { Setup, Present, Vto, Done }

#[derive(PartialEq, Clone, Copy)]
enum Tab { Selector, NameList }

enum Action {
    SwitchToSelector,
    SwitchToNameList,
    Start,
    MarkAbsent,
    ShowVto,
    VtoYes,
    VtoNo,
    ResetList,
    NewSession,
    SaveListEdits,
    ResetFromListTab,
}

// ── App ───────────────────────────────────────────────────────────────────────

struct VtoApp {
    tab: Tab,
    screen: Screen,
    names: Vec<String>,
    vto_count: usize,
    confirmed: usize,
    drawn: HashSet<String>,
    absent: HashSet<String>,
    chosen: String,
    name_list_text: String,
    list_status: String,
    info_msg: String,
    info_is_error: bool,
    vto_accepted: Vec<String>,
}

impl VtoApp {
    fn new() -> Self {
        let names = load_names(&list_file());
        let n = names.len();
        Self {
            tab: Tab::Selector,
            screen: Screen::Setup,
            names,
            vto_count: 1,
            confirmed: 0,
            drawn: HashSet::new(),
            absent: HashSet::new(),
            chosen: String::new(),
            name_list_text: String::new(),
            list_status: format!("{} name(s) in active list", n),
            info_msg: String::new(),
            info_is_error: false,
            vto_accepted: Vec::new(),
        }
    }

    fn draw_next(&mut self) {
        let today = today_str();
        let mut available: Vec<String> = self.names.iter()
            .filter(|n| !self.drawn.contains(*n) && !self.absent.contains(*n))
            .cloned()
            .collect();

        if available.is_empty() {
            if self.names.is_empty() {
                self.names = restore_from_backup();
                log_entry(&format!(
                    "[{}] --- List automatically refreshed (all names selected) ---", today
                ));
            }
            self.drawn.clear();
            available = self.names.iter()
                .filter(|n| !self.absent.contains(*n))
                .cloned()
                .collect();
        }

        if let Some(name) = available.choose(&mut rand::thread_rng()) {
            self.chosen = name.clone();
            self.drawn.insert(self.chosen.clone());
            self.screen = Screen::Present;
        }
    }

    fn refresh_list_tab(&mut self) {
        let names = load_names(&list_file());
        self.name_list_text = names.join("\n");
        self.list_status = format!("{} name(s) in active list", names.len());
    }

    fn apply(&mut self, action: Action) {
        let today = today_str();
        self.info_msg.clear();
        self.info_is_error = false;

        match action {
            Action::SwitchToSelector => { self.tab = Tab::Selector; }
            Action::SwitchToNameList => { self.tab = Tab::NameList; self.refresh_list_tab(); }
            Action::Start => {
                self.names = load_names(&list_file());
                self.confirmed = 0;
                self.drawn.clear();
                self.absent.clear();
                self.vto_accepted.clear();
                self.draw_next();
            }
            Action::MarkAbsent => {
                log_entry(&format!("[{}] {} - Present: No", today, self.chosen));
                self.absent.insert(self.chosen.clone());
                self.draw_next();
            }
            Action::ShowVto => { self.screen = Screen::Vto; }
            Action::VtoYes => {
                log_entry(&format!("[{}] {} - Present: Yes | VTO: Yes", today, self.chosen));
                let chosen = self.chosen.clone();
                self.vto_accepted.push(chosen.clone());
                self.names.retain(|n| n != &chosen);
                save_names(&self.names, &list_file());
                self.confirmed += 1;
                if self.confirmed >= self.vto_count { self.screen = Screen::Done; }
                else { self.draw_next(); }
            }
            Action::VtoNo => {
                log_entry(&format!("[{}] {} - Present: Yes | VTO: No", today, self.chosen));
                let chosen = self.chosen.clone();
                self.names.retain(|n| n != &chosen);
                save_names(&self.names, &list_file());
                self.draw_next();
            }
            Action::ResetList => {
                self.names = reset_preserving_new_names();
                log_entry(&format!("[{}] --- List manually reset ---", today));
                self.refresh_list_tab();
                self.info_msg = "List has been reset to all names.".to_string();
                self.screen = Screen::Setup;
            }
            Action::NewSession => { self.screen = Screen::Setup; self.vto_accepted.clear(); }
            Action::SaveListEdits => {
                let names: Vec<String> = self.name_list_text
                    .lines()
                    .map(|l| l.trim().to_string())
                    .filter(|l| !l.is_empty())
                    .collect();
                if names.is_empty() {
                    self.info_msg = "Cannot save an empty list.".to_string();
                    self.info_is_error = true;
                    return;
                }
                save_names(&names, &list_file());
                if !backup_file().exists() { save_names(&names, &backup_file()); }
                let n = names.len();
                self.names = names;
                self.list_status = format!("{} name(s) in active list", n);
                self.info_msg = format!("{} names saved.", n);
                self.tab = Tab::Selector;
                self.screen = Screen::Setup;
            }
            Action::ResetFromListTab => {
                if !backup_file().exists() {
                    self.info_msg = "No backup file found to reset from.".to_string();
                    self.info_is_error = true;
                    return;
                }
                let names = reset_preserving_new_names();
                log_entry(&format!("[{}] --- List manually reset ---", today));
                let n = names.len();
                self.name_list_text = names.join("\n");
                self.list_status = format!("{} name(s) in active list", n);
                self.names = names;
                self.info_msg = "List has been reset to all names.".to_string();
                self.screen = Screen::Setup;
            }
        }
    }
}

// ── UI ────────────────────────────────────────────────────────────────────────

impl eframe::App for VtoApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        let mut action: Option<Action> = None;

        egui::TopBottomPanel::bottom("vto_footer").show(ctx, |ui| {
            ui.add_space(4.0);
            if self.vto_accepted.is_empty() {
                ui.colored_label(egui::Color32::GRAY, "VTO Accepted: —");
            } else {
                ui.horizontal_wrapped(|ui| {
                    ui.label(egui::RichText::new("VTO Accepted:").strong());
                    for name in &self.vto_accepted {
                        ui.label(egui::RichText::new(name).color(egui::Color32::from_rgb(76, 175, 80)));
                    }
                });
            }
            ui.add_space(4.0);
        });

        egui::CentralPanel::default().show(ctx, |ui| {
            ui.horizontal(|ui| {
                if ui.selectable_label(self.tab == Tab::Selector, "  VTO Selector  ").clicked() {
                    action = Some(Action::SwitchToSelector);
                }
                if ui.selectable_label(self.tab == Tab::NameList, "  Name List  ").clicked() {
                    action = Some(Action::SwitchToNameList);
                }
            });
            ui.separator();

            match self.tab {
                Tab::Selector => match self.screen {
                    Screen::Setup => {
                        ui.vertical_centered(|ui| {
                            ui.add_space(20.0);
                            ui.label(egui::RichText::new("VTO Selector").size(26.0).strong());
                            ui.add_space(4.0);
                            ui.label(format!("Today: {}", today_str()));
                            ui.add_space(16.0);

                            if !list_file().exists() {
                                ui.colored_label(egui::Color32::GRAY,
                                    "No list found — add names in the Name List tab.");
                            } else {
                                ui.label(format!("{} name(s) remaining in list", self.names.len()));
                                ui.add_space(8.0);

                                if backup_file().exists() && ui.button("Reset List to All Names").clicked() {
                                    action = Some(Action::ResetList);
                                }

                                ui.add_space(14.0);
                                ui.label("How many VTO confirmations needed?");
                                ui.add_space(4.0);
                                let max = self.names.len().max(1);
                                ui.add(egui::DragValue::new(&mut self.vto_count).range(1..=max));
                                ui.add_space(18.0);

                                let start_btn = egui::Button::new(
                                    egui::RichText::new("  Start  ").size(15.0).strong()
                                ).fill(egui::Color32::from_rgb(76, 175, 80));
                                if ui.add(start_btn).clicked() { action = Some(Action::Start); }

                                if !self.info_msg.is_empty() {
                                    ui.add_space(10.0);
                                    let color = if self.info_is_error {
                                        egui::Color32::from_rgb(200, 50, 50)
                                    } else {
                                        egui::Color32::from_rgb(30, 150, 30)
                                    };
                                    ui.colored_label(color, &self.info_msg.clone());
                                }
                            }
                        });
                    }
                    Screen::Present => {
                        ui.vertical_centered(|ui| {
                            ui.add_space(16.0);
                            ui.label(format!("VTO Confirmed: {} of {}", self.confirmed, self.vto_count));
                            ui.add_space(10.0);
                            ui.label(egui::RichText::new(&self.chosen).size(30.0).strong());
                            ui.add_space(10.0);
                            ui.label(format!("Is {} present today?", self.chosen));
                            ui.add_space(20.0);
                            ui.horizontal(|ui| {
                                let pad = (ui.available_width() - 90.0 * 2.0 - 20.0) / 2.0;
                                ui.add_space(pad.max(0.0));
                                let yes = egui::Button::new(egui::RichText::new("Yes").size(14.0).strong())
                                    .fill(egui::Color32::from_rgb(76, 175, 80))
                                    .min_size(egui::vec2(90.0, 34.0));
                                let no = egui::Button::new(egui::RichText::new("No").size(14.0).strong())
                                    .fill(egui::Color32::from_rgb(244, 67, 54))
                                    .min_size(egui::vec2(90.0, 34.0));
                                if ui.add(yes).clicked() { action = Some(Action::ShowVto); }
                                ui.add_space(20.0);
                                if ui.add(no).clicked() { action = Some(Action::MarkAbsent); }
                            });
                        });
                    }
                    Screen::Vto => {
                        ui.vertical_centered(|ui| {
                            ui.add_space(16.0);
                            ui.label(format!("VTO Confirmed: {} of {}", self.confirmed, self.vto_count));
                            ui.add_space(10.0);
                            ui.label(egui::RichText::new(&self.chosen).size(30.0).strong());
                            ui.add_space(10.0);
                            ui.label(format!("Would {} like VTO?", self.chosen));
                            ui.add_space(20.0);
                            ui.horizontal(|ui| {
                                let pad = (ui.available_width() - 90.0 * 2.0 - 20.0) / 2.0;
                                ui.add_space(pad.max(0.0));
                                let yes = egui::Button::new(egui::RichText::new("Yes").size(14.0).strong())
                                    .fill(egui::Color32::from_rgb(76, 175, 80))
                                    .min_size(egui::vec2(90.0, 34.0));
                                let no = egui::Button::new(egui::RichText::new("No").size(14.0).strong())
                                    .fill(egui::Color32::from_rgb(244, 67, 54))
                                    .min_size(egui::vec2(90.0, 34.0));
                                if ui.add(yes).clicked() { action = Some(Action::VtoYes); }
                                ui.add_space(20.0);
                                if ui.add(no).clicked() { action = Some(Action::VtoNo); }
                            });
                        });
                    }
                    Screen::Done => {
                        ui.vertical_centered(|ui| {
                            ui.add_space(32.0);
                            ui.label(egui::RichText::new("Done!")
                                .size(34.0).strong()
                                .color(egui::Color32::from_rgb(76, 175, 80)));
                            ui.add_space(10.0);
                            ui.label(format!("{} person(s) confirmed for VTO today.", self.vto_count));
                            ui.colored_label(egui::Color32::GRAY, today_str());
                            ui.add_space(20.0);
                            if ui.button("New Session").clicked() { action = Some(Action::NewSession); }
                            ui.add_space(8.0);
                            if ui.button("Quit").clicked() { std::process::exit(0); }
                        });
                    }
                },

                Tab::NameList => {
                    ui.vertical_centered(|ui| {
                        ui.label(egui::RichText::new("Name List").size(16.0).strong());
                        ui.colored_label(egui::Color32::GRAY, &self.list_status.clone());
                    });
                    ui.add_space(6.0);
                    let text_height = ui.available_height() - 50.0;
                    egui::ScrollArea::vertical().max_height(text_height).show(ui, |ui| {
                        ui.add(egui::TextEdit::multiline(&mut self.name_list_text)
                            .desired_rows(14)
                            .desired_width(f32::INFINITY));
                    });
                    ui.add_space(6.0);
                    ui.horizontal(|ui| {
                        let save_btn = egui::Button::new(egui::RichText::new("Save Changes").strong())
                            .fill(egui::Color32::from_rgb(76, 175, 80));
                        if ui.add(save_btn).clicked() { action = Some(Action::SaveListEdits); }
                        if ui.button("Reset to Full List").clicked() { action = Some(Action::ResetFromListTab); }
                    });
                    if !self.info_msg.is_empty() {
                        let color = if self.info_is_error {
                            egui::Color32::from_rgb(200, 50, 50)
                        } else {
                            egui::Color32::from_rgb(30, 150, 30)
                        };
                        ui.colored_label(color, &self.info_msg.clone());
                    }
                }
            }
        });

        if let Some(a) = action { self.apply(a); }
    }
}

// ── Entry point ───────────────────────────────────────────────────────────────

fn main() -> eframe::Result<()> {
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([500.0, 460.0])
            .with_resizable(false)
            .with_title("VTO Selector"),
        ..Default::default()
    };
    eframe::run_native(
        "VTO Selector",
        options,
        Box::new(|_cc| Ok(Box::new(VtoApp::new()))),
    )
}
