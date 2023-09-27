
Racmacs.utils.Checkbox = class Checkbox {

	constructor(args){

		this.div = document.createElement("div");
		this.div.style.display = "inline-block";

	    var label = document.createElement("label");
	    label.classList.add("checkbox-container");
	    
	    var checkbox = document.createElement("input");
	    checkbox.type = "checkbox";
	    checkbox.value = args.value;
	    checkbox.addEventListener("change", function(){
	    	if(this.checked){ args.check_fn()   }
	    	else            { args.uncheck_fn() }
	    });
	    
	    var checkmark = document.createElement("span");
	    checkmark.classList.add("checkmark");
	    checkmark.classList.add("checkbox-checkmark");
	    
	    if(args.col){
	    	checkmark.style.backgroundColor = args.col;
	    }
	    
	    if(args.text){
	    	label.innerHTML = args.text;
		}
	    
	    label.appendChild(checkbox);
	    label.appendChild(checkmark);
	    label.checkbox = checkbox;

	    this.checkbox     = checkbox;
	    this.checkmark    = checkmark;
	    this.check_fn   = args.check_fn;
	    this.uncheck_fn = args.uncheck_fn;
	    
	    this.div.appendChild(label);

	}

	check(callback = true){
		if(callback) this.check_fn();
		this.checkbox.checked = true;
	}

	uncheck(callback = true){
		if(callback) this.uncheck_fn();
		this.checkbox.checked = false;
	}

	enable(){
		this.checkbox.removeAttribute("disabled");
		this.checkmark.classList.remove("checkbox-disabled");
	}

	disable(){
		this.checkbox.setAttribute("disabled", true);
		this.checkmark.classList.add("checkbox-disabled");
	}

}


Racmacs.utils.Button = class Button {

	constructor(args){

		this.div = document.createElement("div");
	    this.div.classList.add("not-selectable");
		this.div.classList.add("control-btn");
		this.div.innerHTML = args.label;

		this.div.addEventListener("mouseup", args.fn);

	}

}

Racmacs.utils.InputWell = class InputWell {

	constructor(args){

		// Holder div
		this.div = document.createElement("div");
		this.div.classList.add("control-input-holder");

		this.well = document.createElement("div");
		this.well.classList.add("control-input-well");
		this.well.style.marginBottom = "6px";
		this.div.appendChild(this.well);

		// Input buttons
		this.inputtable = document.createElement("table");
		this.well.appendChild(this.inputtable);

		this.inputs = [];
		for(var i=0; i<args.inputs.length; i++){
			
			var input = document.createElement("input");
			input.classList.add("control-input");
			input.value = args.inputs[i].value;
			input.id = args.inputs[i].id;
			this.inputs.push(input);

			var row = document.createElement("tr");
			this.inputtable.appendChild(row);

			var labelcol = document.createElement("td");
			labelcol.classList.add("control-label");
			row.appendChild(labelcol);
			labelcol.innerHTML = args.inputs[i].label;

			var inputcol = document.createElement("td");
			row.appendChild(inputcol);
			inputcol.appendChild(input);

		}

		// Submit button
		var inputwell = this;
		this.submit = new Racmacs.utils.Button({
			label : args.submit,
			fn : function(){ 
				var inputargs = {};
				for(var i=0; i<inputwell.inputs.length; i++){
					inputargs[inputwell.inputs[i].id] = inputwell.inputs[i].value;
				}
				args.fn(inputargs);
			}
		});
		this.div.appendChild(this.submit.div);
		this.div.style.textAlign = "right";

	}

}


Racmacs.utils.RemoveColorOpacity = function(col) {

    if (col.match(/^#([A-Z]|[0-9]|[a-z]){8}$/)) {
    	col = col.replace(/.{2}$/, "");
    }
    return(col);

}

Racmacs.utils.ExtractColorOpacity = function(col) {

    if (col == "transparent") {
    	return(0);
    } else if (col.match(/^#([A-Z]|[0-9]|[a-z]){8}$/)) {
    	opacity = col.match(/.{2}$/)[0];
    	return(parseInt(opacity, 16) / 255);
    } else {
    	return(1);
    }

}


Racmacs.utils.matrixMultiply = function(t1, t2){

	return([
		t1[0]*t2[0]+t1[2]*t2[1],
		t1[0]*t2[2]+t1[2]*t2[3],
		t1[1]*t2[0]+t1[3]*t2[1],
		t1[1]*t2[2]+t1[3]*t2[3],
	]);

}



Racmacs.utils.transformCoords = function(
	coords, 
	transformation
){  

	if(coords[0] === null) return(coords);

    if(coords.length == 1){

    	return(coords[0]*transformation[0]);

    } else if(coords.length == 2){
    	
 		if(transformation.length == 4){
	    	// Standard 2D transform
	    	return([
                coords[0]*transformation[0] + coords[1]*transformation[1],
                coords[0]*transformation[2] + coords[1]*transformation[3]
	        ]);
	    } else {
	    	// 2D to 3D transform
	    	return([
	    		coords[0]*transformation[0] + coords[1]*transformation[1],
                coords[0]*transformation[2] + coords[1]*transformation[3],
                coords[0]*transformation[4] + coords[1]*transformation[5]
	    	]);
	    }

    } else if(coords.length == 3) {

    	if(transformation.length == 9){
	    	// Standard 3D transform
	    	return([
                coords[0]*transformation[0] + coords[1]*transformation[3] + coords[2]*transformation[6],
                coords[0]*transformation[1] + coords[1]*transformation[4] + coords[2]*transformation[7],
                coords[0]*transformation[2] + coords[1]*transformation[5] + coords[2]*transformation[8]
	        ]);
	    } else {
	    	// Standard 3D coords with 2D transform
	    	return([
                coords[0]*transformation[0] + coords[1]*transformation[2],
                coords[0]*transformation[1] + coords[1]*transformation[3],
                coords[2]
	        ]);
	    }

    } else {

    	throw("Cannot view more than 3 dimensions.");

    }

}


Racmacs.utils.translateCoords = function(
	coords, 
	translation
){

	if(coords[0] === null) return(coords);

    if(coords.length == 1){

    	return(coords[0]+translation[0]);

    } else if(coords.length == 2){
    	
    	if(translation.length == 2){
	    	// Standard 2D translation
	    	return([
	                coords[0]+translation[0],
	                coords[1]+translation[1]
	        ]);
    	} else {
    		// 3D translation on 2D coords
    		return([
	                coords[0]+translation[0],
	                coords[1]+translation[1],
	                translation[2]
	        ]);
    	}

    } else if(coords.length == 3) {

    	if(translation.length == 3){
	    	// Standard 3D translation
	    	return([
	                coords[0]+translation[0],
	                coords[1]+translation[1],
	                coords[2]+translation[2]
	        ]);
	    } else {
	    	// 2D translation on 3D coords
	    	return([
	                coords[0]+translation[0],
	                coords[1]+translation[1],
	                coords[2]
	        ]);
	    }

    } else {

    	throw("Cannot view more than 3 dimensions.");
    	
    }

}


Racmacs.utils.transformTranslateCoords = function(
	coords, 
	transformation,
	translation
){

	if (transformation !== null) { 
		coords = Racmacs.utils.transformCoords(coords, transformation);
	}
    if (translation !== null) { 
    	coords = Racmacs.utils.translateCoords(coords, translation);
    }
    return(coords);

}


Racmacs.utils.distBetweenPoints = function(
	coords1,
	coords2
){

	var x1 = coords1[0];
    var y1 = coords1[0];
    var x2 = coords2[1];
    var y2 = coords2[1];
    return(Math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1)));

}


Racmacs.utils.lineBetweenPoints = function(
	coords1,
	coords2,
	endgap
){

	var x1 = coords1[0];
    var y1 = coords1[0];
    var x2 = coords2[1];
    var y2 = coords2[1];
    var angle = Math.atan2(y2 - y1, x2 - x1);
    var targetx = x2 - Math.cos(angle)*endgap;
    var targety = y2 - Math.sin(angle)*endgap;
    return({
    	x: targetx,
    	y: targety
    });

}


Racmacs.utils.lineTowardsPoint = function(
	coords1,
	coords2,
	linelength
){

	var x1 = coords1[i];
    var y1 = coords1[i];
    var x2 = coords2[i];
    var y2 = coords2[i];
    var angle = Math.atan2(y2 - y1, x2 - x1);
    var targetx = x1 + Math.cos(angle)*linelength;
    var targety = y1 + Math.sin(angle)*linelength;
    var length  = Math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
    return({
    	x: targetx,
    	y: targety
    });

}

Racmacs.utils.colorPalette = [
  new THREE.Color("#ff0004"),
  new THREE.Color("#0084f0"),
  new THREE.Color("#14ed0c"),
  new THREE.Color("#d000f0"),
  new THREE.Color("#ff7f00"),
  new THREE.Color("#ffff33"),
  new THREE.Color("#cc4b00"),
  new THREE.Color("#ff7ac1")
];

//     inputs: [
//         { id: "numruns",     label : "Number of optimisations" },
//         { id: "mincolbasis", label : "Minimum column basis" }
//     ],
//     submit: "Run optimisations",
//     fn : function(args){ viewer.onRunOptimizations(args) }
// })
