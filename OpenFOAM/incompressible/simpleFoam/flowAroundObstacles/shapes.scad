fn=100;

boxLength=260;
boxHeight=120;
boxWidth=10;

// Domain
// cube([boxLength, boxWidth, boxHeight],true);
// Shapes
// doCylinder(25, 0, 0);
// doHalfCylinder(50, 0, 0, 50);
// doHexagonal(50, 0, 0);
// doEllipse(50, 0, 0, 10);
// doSquare(50, 0, 0, 0);


module doCylinder(d, dx, dz){
    color([0.15,0.15,0.15])
        translate([dx,0,dz])
            rotate([90,0,0])
                cylinder(h=boxWidth*3, d=d, center=true, $fn=fn);
}

module doHalfCylinder(d, dx, dz, a){
    color([0.15,0.15,0.15])
    rotate([0,a,0])
    difference() {
        translate([dx,0,dz])
            rotate([90,0,0])
                cylinder(h=boxWidth*3, d=d, center=true, $fn=fn);
        translate([d*0.5,0,0])
             doSquare(d, dx, dz, 0);
    }
}

module doEllipse(d, dx, dz, a){
    color([0.15,0.15,0.15])
        translate([dx,0,dz])
            rotate([90,a,0])
                scale([1.25,1.0])
                    cylinder(h=boxWidth*3, d=d, center=true, $fn=fn);
}

module doHexagonal(d, dx, dz, a){
    color([0.15,0.15,0.15])
        translate([dx,0,dz])
            rotate([90,a,0])
                cylinder(h=boxWidth*3, d=d, center=true, $fn=6);
}


module doSquare(l, dx, dz, a){
    color([0.15,0.15,0.15])
        translate([dx,0,dz])
            rotate([90,a,0])
                cube([l, l, boxWidth*3],true);    
}

module importSTL(stlName, scaleFactor, dx, dy, dz, anglex, angley, anglez){
    scale(scaleFactor)
    rotate([anglex,angley,anglez]) 
        translate([dx,dy,dz])
            import(stlName, convexity=3);
}

module export(shape="circle") {
  if (shape=="circle") scale(0.001) doCylinder(diameter, dx, dz);
  if (shape=="halfCircle") scale(0.001) doHalfCylinder(diameter, dx, dz, angle);
  if (shape=="ellipse") scale(0.001) doEllipse(diameter, dx, dz, angle);
  if (shape=="hexagonal") scale(0.001) doHexagonal(diameter, dx, dz, angle);
  if (shape=="square") scale(0.001) doSquare(side, dx, dz, angle);
  if (shape=="stl") scale(0.001) importSTL(stlName, scaleFactor, dx, dy, dz, anglex, angley, anglez);
}

shape = "circle";
stlName = "aaaa";
scaleFactor = 0;
diameter = 0;
side = 0;
angle = 0;
anglex = 0;
angley = 0;
anglez = 0;
dx = 0;
dy = 0;
dz = 0;

echo (shape)

export(shape);
