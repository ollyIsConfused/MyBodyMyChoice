// Lautsprecherbox nach Handskizze: 40 x 30 cm, Tieftoener Oe 18 cm, Bassreflex
// Einheiten: mm.  Koordinaten: x = Breite (links -> rechts),
//                 y = Tiefe (Front bei y = 0), z = Hoehe (Boden bei z = 0)
//
// Ansichten (oben bei "ansicht" umstellen oder per Kommandozeile -D):
//   "zusammenbau" – fertige Box mit Chassis (Vorschau)
//   "explosion"   – alle Platten auseinandergezogen (zum Verstehen der Verbindung)
//   "rohr"        – nur das 3D-druckbare Bassreflexrohr (-> STL exportieren)
//   "front"       – Frontplatte flach, zum Ausdrucken/Anzeichnen der Bohrungen
//
// Material-Empfehlung: MDF 19 mm (siehe README). Fuer Birke-Multiplex 18 mm
// einfach wand = 18 setzen – alle Zuschnitte rechnen sich selbst neu.

ansicht = "zusammenbau";

$fn = 96;

// ---------- Aussenmasse ----------
breite = 400;   // aus Skizze (40 cm)
tiefe  = 300;   // aus Skizze (30 cm)
hoehe  = 250;   // FEHLTE in der Skizze -> festgelegt: 25 cm (~18,5 L netto)
wand   = 19;    // Plattenstaerke (MDF 19 mm)

// ---------- Tieftoener (aus Skizze) ----------
chassis_d    = 180;   // Aussendurchmesser Korb (Oe 18 cm)
ausschnitt_d = 155;   // Einbauausschnitt (155 mm)
chassis_x    = 270;   // Mitte, ab linker Aussenkante  (festgelegt)
chassis_z    = hoehe / 2; // Mitte, ab Unterkante      (festgelegt)
chassis_tiefe = 85;   // Einbautiefe, nur fuer Vorschau/Kollisionscheck

// ---------- Bassreflexrohr (3D-Druck) ----------
rohr_innen_d  = 50;   // Innendurchmesser
rohr_wand     = 3;    // -> aussen 56 mm, Lochsaege 57 mm
rohr_laenge   = 120;  // Gesamtlaenge inkl. Flansch -> ca. 45 Hz bei 18,5 L
flansch_d     = 90;
flansch_h     = 10;
flare_d       = 66;   // Trichteroeffnung vorne (45 Grad, ohne Stuetzen druckbar)
rohr_x        = 90;   // Mitte, ab linker Aussenkante (kleiner Kreis der Skizze)
rohr_z        = hoehe / 2;
loch_rohr_d   = 57;   // Lochsaege fuer das Rohr in der Front

// ---------- Deckel: Bedienfeld / Verstaerkermodul (schraffiert in Skizze) ----------
bedienfeld    = [150, 70];   // PLATZHALTER -> an dein Modul anpassen
bedienfeld_x  = 140;         // Mitte, ab linker Aussenkante
bedienfeld_y  = tiefe / 2;   // Mitte, ab Vorderkante

// ---------- Rueckwand: Anschluss (Netzteil-/Klinkenbuchse) ----------
anschluss_d   = 12;
anschluss_x   = 60;
anschluss_z   = 60;

// ---------- Versteifung ----------
strebe_d      = 25;   // Rundholz Buche Oe 25 mm, Deckel <-> Boden
strebe_x      = 310;
strebe_y      = 200;

// ---------- abgeleitete Masse ----------
innen   = [breite - 2 * wand, tiefe - 2 * wand, hoehe - 2 * wand];
seite   = [tiefe, hoehe - 2 * wand];                // 2x
frontrk = [breite - 2 * wand, hoehe - 2 * wand];    // 2x (Front + Rueckwand)
deckel  = [breite, tiefe];                          // 2x (Deckel + Boden)

holz    = [0.78, 0.62, 0.45];
schwarz = [0.12, 0.12, 0.12];

// ---------- Platten ----------
module boden()  { cube([breite, tiefe, wand]); }

module deckel() {
    difference() {
        translate([0, 0, hoehe - wand]) cube([breite, tiefe, wand]);
        translate([bedienfeld_x - bedienfeld[0] / 2, bedienfeld_y - bedienfeld[1] / 2, hoehe - wand - 1])
            cube([bedienfeld[0], bedienfeld[1], wand + 2]);
    }
}

module seite_links()  { translate([0, 0, wand]) cube([wand, tiefe, hoehe - 2 * wand]); }
module seite_rechts() { translate([breite - wand, 0, wand]) cube([wand, tiefe, hoehe - 2 * wand]); }

module front() {
    difference() {
        translate([wand, 0, wand]) cube([breite - 2 * wand, wand, hoehe - 2 * wand]);
        translate([chassis_x, -1, chassis_z]) rotate([-90, 0, 0]) cylinder(d = ausschnitt_d, h = wand + 2);
        translate([rohr_x, -1, rohr_z])       rotate([-90, 0, 0]) cylinder(d = loch_rohr_d,  h = wand + 2);
    }
}

module rueckwand() {
    difference() {
        translate([wand, tiefe - wand, wand]) cube([breite - 2 * wand, wand, hoehe - 2 * wand]);
        translate([anschluss_x, tiefe - wand - 1, anschluss_z]) rotate([-90, 0, 0])
            cylinder(d = anschluss_d, h = wand + 2);
    }
}

module strebe() { translate([strebe_x, strebe_y, wand]) cylinder(d = strebe_d, h = hoehe - 2 * wand); }

// ---------- Bassreflexrohr (druckbar: Flansch nach unten aufs Bett) ----------
module bassreflexrohr() {
    difference() {
        union() {
            // Flansch mit abgefaster Aussenkante
            cylinder(d1 = flansch_d - 4, d2 = flansch_d, h = 2);
            translate([0, 0, 2]) cylinder(d = flansch_d, h = flansch_h - 2);
            cylinder(d = rohr_innen_d + 2 * rohr_wand, h = rohr_laenge);
        }
        // Bohrung + 45-Grad-Trichter an der Frontseite
        translate([0, 0, -1]) cylinder(d = rohr_innen_d, h = rohr_laenge + 2);
        translate([0, 0, -0.01]) cylinder(d1 = flare_d, d2 = rohr_innen_d, h = (flare_d - rohr_innen_d) / 2);
        // kleine Fase am inneren Ende
        translate([0, 0, rohr_laenge - 1.5]) cylinder(d1 = rohr_innen_d, d2 = rohr_innen_d + 3, h = 1.51);
        // 3 Schraubloecher (3,5 mm Holzschrauben, Senkkopf)
        for (w = [90, 210, 330]) rotate([0, 0, w]) translate([(flansch_d + flare_d) / 4 + 0.5, 0, 0]) {
            translate([0, 0, -1]) cylinder(d = 3.8, h = flansch_h + 2);
            translate([0, 0, -0.01]) cylinder(d1 = 7.5, d2 = 3.8, h = 1.9);
        }
    }
}

// ---------- Tieftoener (nur Vorschau) ----------
module tieftoener() {
    color(schwarz) translate([chassis_x, 0, chassis_z]) rotate([90, 0, 0]) {
        difference() {
            cylinder(d = chassis_d, h = 6);
            translate([0, 0, 2]) cylinder(d1 = chassis_d - 40, d2 = chassis_d - 24, h = 5);
        }
        translate([0, 0, 6]) cylinder(d = chassis_d - 24, h = 1); // Sicke-Andeutung
        color([0.3, 0.3, 0.3]) translate([0, 0, 1]) sphere(d = 45);       // Staubschutzkappe
        mirror([0, 0, 1]) cylinder(d1 = ausschnitt_d - 4, d2 = 70, h = chassis_tiefe - 30);
        mirror([0, 0, 1]) translate([0, 0, chassis_tiefe - 35]) cylinder(d = 100, h = 35);
    }
}

// ---------- Zusammenbau ----------
module gehaeuse() {
    color(holz) boden();
    color(holz) deckel();
    color(holz * 0.92) seite_links();
    color(holz * 0.92) seite_rechts();
    color(holz * 0.85) front();
    color(holz * 0.85) rueckwand();
    color([0.6, 0.45, 0.3]) strebe();
}

module zusammenbau() {
    gehaeuse();
    tieftoener();
    // Flansch sitzt aussen auf der Front, Rohr ragt nach innen
    color([0.2, 0.2, 0.22]) translate([rohr_x, -flansch_h, rohr_z]) rotate([-90, 0, 0]) bassreflexrohr();
}

module explosion(a = 120) {
    color(holz) translate([0, 0, -a]) boden();
    color(holz) translate([0, 0, a]) deckel();
    color(holz * 0.92) translate([-a, 0, 0]) seite_links();
    color(holz * 0.92) translate([a, 0, 0]) seite_rechts();
    color(holz * 0.85) translate([0, -a, 0]) front();
    color(holz * 0.85) translate([0, a, 0]) rueckwand();
    color([0.6, 0.45, 0.3]) strebe();
}

if (ansicht == "zusammenbau") zusammenbau();
else if (ansicht == "explosion") explosion();
else if (ansicht == "rohr") bassreflexrohr();
else if (ansicht == "front")
    // Frontplatte flach (Blick von vorne), Ursprung = linke untere Ecke der Platte
    projection() rotate([-90, 0, 0]) translate([-wand, 0, -wand]) front();

// ---------- Zuschnittliste + Volumen in der Konsole ----------
brutto_l = innen[0] * innen[1] * innen[2] / 1e6;
abzug_l  = 1.0                                                        // Chassis (typ. 18-cm-Tieftoener)
         + PI * pow((rohr_innen_d + 2 * rohr_wand) / 2, 2) * (rohr_laenge - flansch_h) / 1e6
         + PI * pow(strebe_d / 2, 2) * innen[2] / 1e6
         + 0.2;                                                       // Verstaerkermodul
netto_l  = brutto_l - abzug_l;
d_cm     = rohr_innen_d / 10;
fb       = sqrt(23562.5 * d_cm * d_cm / (netto_l * (rohr_laenge / 10 + 0.732 * d_cm)));

echo(str("ZUSCHNITT  2x Deckel/Boden ", deckel[0], " x ", deckel[1], " mm"));
echo(str("ZUSCHNITT  2x Seiten       ", seite[0], " x ", seite[1], " mm"));
echo(str("ZUSCHNITT  2x Front/Rueck  ", frontrk[0], " x ", frontrk[1], " mm"));
echo(str("VOLUMEN    brutto ", brutto_l, " L, netto ca. ", netto_l, " L"));
echo(str("ABSTIMMUNG Bassreflex ca. ", fb, " Hz"));
