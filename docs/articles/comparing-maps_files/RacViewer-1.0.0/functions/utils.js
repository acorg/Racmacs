
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

    if(coords.length == 2){
    	
 		if(transformation.length == 4){
	    	// Standard 2D transform
	    	return([
                coords[0]*transformation[0] + coords[1]*transformation[2],
                coords[0]*transformation[1] + coords[1]*transformation[3]
	        ]);
	    } else {
	    	// 2D to 3D transform
	    	return([
	    		coords[0]*transformation[0] + coords[1]*transformation[3],
                coords[0]*transformation[1] + coords[1]*transformation[4],
                coords[0]*transformation[2] + coords[1]*transformation[5]
	    	]);
	    }

    } else {

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

    }

}


Racmacs.utils.translateCoords = function(
	coords, 
	translation
){

    if(coords.length == 2){
    	
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

    } else {

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

    }

}


Racmacs.utils.transformTranslateCoords = function(
	coords, 
	transformation,
	translation
){
    
    coords = Racmacs.utils.transformCoords(coords, transformation);
    coords = Racmacs.utils.translateCoords(coords, translation);
    return(coords);

}



//     inputs: [
//         { id: "numruns",     label : "Number of optimisations" },
//         { id: "mincolbasis", label : "Minimum column basis" }
//     ],
//     submit: "Run optimisations",
//     fn : function(args){ viewer.onRunOptimizations(args) }
// })
