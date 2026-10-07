// Anschauungsmodell (Display) – NICHT ZUM TRAGEN
// Aufgeschnittene Halbschale, fest mit einem Sockel verbunden.
// Statt Haken: stumpfe, halbrunde Noppen. Rein zur Veranschaulichung.
// Einheiten: mm. Drucklage: Sockel flach auf dem Druckbett, ohne Stuetzen.

$fn = 64;

// ---------- Parameter ----------
laenge      = 110;   // Laenge der Halbschale
r_aussen    = 22;    // Aussenradius
wand        = 3;     // Wandstaerke
r_innen     = r_aussen - wand;

noppe_r     = 2.5;   // Radius der stumpfen Noppen (Halbkugeln)
noppe_reihen_abstand = 11;  // Abstand der Noppenreihen entlang der Laenge
noppe_winkel = [-60, -30, 0, 30, 60]; // Lage der Noppen um die Achse (0 = unten)

rippe_abstand = 18;  // aeussere Ringrippen (Optik wie im Bild)
rippe_hoehe   = 1.5;
rippe_breite  = 3;

sockel_l    = 150;
sockel_b    = 85;
sockel_h    = 6;
sockel_rund = 6;

text_zeile1 = "ANSCHAUUNGSMODELL";
text_zeile2 = "NICHT ZUM TRAGEN";
schrift     = "Liberation Sans:style=Bold";
gravur_tiefe = 0.8;

// Achse der Halbschale (liegt auf Hoehe Sockel + Aussenradius)
achse_z = sockel_h + r_aussen;
achse_y = sockel_b - r_aussen - 8;
start_x = (sockel_l - laenge) / 2;

// ---------- Module ----------
module sockel() {
    difference() {
        hull() for (x = [sockel_rund, sockel_l - sockel_rund],
                    y = [sockel_rund, sockel_b - sockel_rund])
            translate([x, y, 0]) cylinder(r = sockel_rund, h = sockel_h);
        // Gravur vorne
        translate([sockel_l / 2, 19, sockel_h - gravur_tiefe])
            linear_extrude(gravur_tiefe + 0.1)
                text(text_zeile1, size = 7, font = schrift, halign = "center", valign = "center");
        translate([sockel_l / 2, 8, sockel_h - gravur_tiefe])
            linear_extrude(gravur_tiefe + 0.1)
                text(text_zeile2, size = 6, font = schrift, halign = "center", valign = "center");
    }
}

// Rohr entlang X, Achse im Ursprung
module rohr_x(r, l) { rotate([0, 90, 0]) cylinder(r = r, h = l); }

module aussenform() {
    // Rohrkoerper + geschlossenes, abgerundetes Ende + Ringrippen
    rohr_x(r_aussen, laenge);
    sphere(r = r_aussen);
    for (x = [rippe_abstand / 2 : rippe_abstand : laenge - rippe_breite])
        translate([x, 0, 0]) rohr_x(r_aussen + rippe_hoehe, rippe_breite);
}

module innenform() {
    translate([0, 0, 0]) rohr_x(r_innen, laenge + 1);
    sphere(r = r_innen);
}

module noppen() {
    for (x = [noppe_reihen_abstand / 2 : noppe_reihen_abstand : laenge - noppe_reihen_abstand / 2],
         w = noppe_winkel)
        rotate([w, 0, 0])
            translate([x, 0, -r_innen]) sphere(r = noppe_r);
}

module halbschale() {
    intersection() {
        union() {
            difference() { aussenform(); innenform(); }
            noppen();
            // Fuss: verbindet die Schale flaechig mit dem Sockel
            difference() {
                translate([-r_aussen * 0.6, -r_aussen * 0.55, -r_aussen])
                    cube([laenge + r_aussen * 0.6, r_aussen * 1.1, r_aussen * 0.5]);
                innenform();
            }
        }
        // nur untere Haelfte -> offene Rinne, kann nicht getragen werden
        translate([-r_aussen - 5, -r_aussen - 5, -r_aussen - 1])
            cube([laenge + 2 * r_aussen + 10, 2 * r_aussen + 10, r_aussen + 1]);
    }
}

// ---------- Zusammenbau ----------
union() {
    sockel();
    translate([start_x + r_aussen / 2, achse_y, achse_z]) halbschale();
}
