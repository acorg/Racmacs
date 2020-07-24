

R3JS.Viewer.prototype.addViewerButtons = function(){

	this.btns = {};
	
	// Create button to show viewer info
	this.addButton({
		name  : "info",
		title : "Show info",
		icon  : R3JS.icons.info(),
		fn    : e => this.viewport.transform_info.toggle()
	});


	// Create button to re-center plot
	this.addButton({
		name  : "resetTransformation",
		title : "Reset orientation",
		icon  : R3JS.icons.center(),
		fn    : e => this.resetTransformation()
	});

	// Create button to download image
	this.addButton({
		name  : "snapshot",
		title : "Download image",
		icon  : R3JS.icons.snapshot(),
		fn    : e => this.downloadImage(this.name)
	});

	// Pop out viewer
	// if (window!=window.top) {
	// 	this.addButton({
	// 		name  : "openInNewWindow",
	// 		title : "Open in new window",
	// 		icon  : icon_open(),
	// 		fn    : e => this.popOutViewer()
	// 	})
    // }

 // 	this.addButton({
	// 	name  : "openInNewWindow",
	// 	title : "Open in new window",
	// 	icon  : R3JS.icons.open(),
	// 	fn    : e => this.popOutViewer()
	// });

}

R3JS.Viewport.prototype.addButtons = function(){

	var viewer = this.viewer;

    // Create button viewport
    var btn_holder = document.createElement( 'div' );
    btn_holder.color = "#999999";
    btn_holder.classList.add('glyph-holder');
    btn_holder.style.color = btn_holder.color;
    btn_holder.style.display = "none";
    btn_holder.style.background = "white";
    this.div.appendChild(btn_holder);
    this.viewer.btnHolder = btn_holder;

    // Add mouseover events to show and hide buttons
    this.div.addEventListener("mouseover", function(){
    	if(viewer.contentLoaded){
    		btn_holder.style.display = "block";
    	}
    });
    this.div.addEventListener("mouseout", function(){
    	btn_holder.style.display = "none";
    });

    // Add viewer buttons
    viewer.addViewerButtons();

}

R3JS.Viewport.prototype.popOutViewer = function(){
	window.open(window.location.href);
}

R3JS.Viewer.prototype.addButton = function(args, position){

	// Create and style button
	var btn = document.createElement( 'div' );
    btn.classList.add("glyph-btn");
    btn.classList.add('not-selectable');
    btn.title     = args.title;
    btn.innerHTML = args.icon;
    this.btns[args.name] = btn;

    // Add button record
    if(typeof(position) === "undefined"){
    	this.btnHolder.appendChild(btn);
	} else {
		this.btnHolder.insertBefore(btn, this.btnHolder.children[position]);
	}

    // Add event listeners
    btn.addEventListener('mousedown', function(e){
    	e.stopPropagation();
    });
    btn.addEventListener('mouseup', function(e){
    	args.fn(e);
    	e.stopPropagation();
    });

    // Add method to update the button
    btn.updateIcon = function(icon){
    	this.innerHTML = icon;
    }

    return(btn);

}




