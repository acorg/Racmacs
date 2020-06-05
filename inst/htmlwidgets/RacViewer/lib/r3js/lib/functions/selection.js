
// Rectangle selections ----------
R3JS.Viewer.prototype.addRectangleSelection = function(){
    
	// Add rectangular selection div
    this.viewport.selectRect = new R3JS.SelectionRectangle();
    this.viewport.div.appendChild(this.viewport.selectRect.div);

    // Bind event listeners
    var viewer = this;
    this.viewport.div.addEventListener('mousedown', function(){
    	viewer.start_rect_select();
    });
    this.viewport.div.addEventListener('mouseup', function(){
        viewer.make_rect_selection();
    });
    this.viewport.div.addEventListener('mousemove', function(){
    	viewer.rect_select();
    });

}

R3JS.SelectionRectangle = class SelectionRectangle {

	constructor(){

		this.div = document.createElement( 'div' );
	    this.div.style.display = "none";
	    this.div.style.backgroundColor = "rgba(0,0,255,0.1)";
	    this.div.style.border = "solid 1px rgba(0,0,255,0.2)";
	    this.div.style.position = "absolute";

	}

	show(){ this.div.style.display = null   }
	hide(){ this.div.style.display = "none" }

	setDimensions(args){

		this.div.style.top    = args.top+"px";
		this.div.style.left   = args.left+"px";
		this.div.style.width  = args.width+"px";
		this.div.style.height = args.height+"px";

	}

}

// Selection rectangle functions
R3JS.Viewer.prototype.start_rect_select = function(){

	if(this.viewport.keydown && this.viewport.keydown.key == "Shift"){
		this.viewport.downmouse = {x: this.viewport.mouse.x, y:this.viewport.mouse.y};
		this.selectRectMode = true;
	}

}

R3JS.Viewer.prototype.end_rect_select = function(){

	this.viewport.selectRect.hide();
	this.selectRectMode = false;
	this.updatePointStyles();

}

R3JS.Viewer.prototype.rect_select = function(){

	if(this.selectRectMode){

		this.viewport.selectRect.show();
		var mouse = this.viewport.mouse;
		var downmouse = this.viewport.downmouse;
		var viewport = this.viewport;
		mouse.down = true;
		
		var left_point   = Math.min(mouse.x, downmouse.x);
		var right_point  = Math.max(mouse.x, downmouse.x);
		var bottom_point = Math.min(mouse.y, downmouse.y);
		var top_point    = Math.max(mouse.y, downmouse.y);

		this.viewport.selectRect.setDimensions({

			top    : ((1-(top_point+1)/2)*viewport.getHeight()),
			left   : (((left_point+1)/2)*viewport.getWidth()),
			width  : (((right_point - left_point)/2)*viewport.getWidth()),
			height : (((top_point - bottom_point)/2)*viewport.getHeight())

		});

	}

}


R3JS.Viewer.prototype.make_rect_selection = function(){

    if(this.selectRectMode){
		for(var i=0; i<this.scene.selectable_elements.length; i++){
			if(this.scene.selectable_elements[i].withinRectangle(
				this.viewport.mouse, 
				this.viewport.downmouse,
				this.camera
			)){
				this.scene.selectable_elements[i].rectangleSelect();
			}
		}
	    this.end_rect_select();
	}

}

