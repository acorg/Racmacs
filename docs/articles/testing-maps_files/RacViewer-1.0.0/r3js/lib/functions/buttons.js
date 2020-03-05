

R3JS.Viewport.prototype.addButtons = function(){

	var viewer = this.viewer;
	this.btns = {};

    // Create button viewport
    var btn_holder = document.createElement( 'div' );
    btn_holder.color = "#999999";
    btn_holder.classList.add('glyph-holder');
    btn_holder.style.color = btn_holder.color;
    btn_holder.style.display = "none";
    btn_holder.style.background = "white";
    this.div.appendChild(btn_holder);
    this.btnHolder = btn_holder;


    // Add mouseover events to show and hide buttons
    this.div.addEventListener("mouseover", function(){
    	// if(viewer.contentLoaded){
    		btn_holder.style.display = "block";
    	// }
    });
    this.div.addEventListener("mouseout", function(){
    	btn_holder.style.display = "none";
    });


	// Create button to show viewer info
	var viewport = this;
	function show_info(){
		viewport.transform_info.toggle();
	}
	this.addButton({
		name  : "info",
		title : "Show info",
		icon  : icon_info(),
		fn    : show_info
	})


	// Create button to re-center plot
    function btn_centerScene(){
    	viewer.resetTransformation();
    }
	this.addButton({
		name  : "resetTransformation",
		title : "Reset orientation",
		icon  : icon_center(),
		fn    : btn_centerScene
	})

	// Create button to download image
	function btn_saveImg(){
      	viewer.downloadImage(viewer.name);
	}
	this.addButton({
		name  : "snapshot",
		title : "Download image",
		icon  : icon_snapshot(),
		fn    : btn_saveImg
	})

	// Pop out viewer
	if (window!=window.top) {
		function popOutViewer(){
			window.open(window.location.href);
		}
		this.addButton({
			name  : "openInNewWindow",
			title : "Open in new window",
			icon  : icon_open(),
			fn    : popOutViewer
		})
    }


}

R3JS.Viewport.prototype.addButton = function(args, position){

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




