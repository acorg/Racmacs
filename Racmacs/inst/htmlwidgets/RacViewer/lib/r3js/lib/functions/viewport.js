
R3JS.Viewport = class Viewport{

    constructor(viewer){

        // Set mouse defaults
        this.mouse       = new THREE.Vector2();
        this.mouse.down  = false;
        this.mouse.over  = false;
        this.mouse.moved = false;
        this.touch       = {num:0};
        this.onresize    = [];
        this.keydown     = null;

        // Bind the viewport to the viewer
        viewer.viewport = this;
        this.viewer = viewer;

        // Create holder
        this.holder = document.createElement( 'div' );
        this.holder.id = "viewport";

        // Create div
        this.div = document.createElement( 'div' );
        this.holder.appendChild(this.div);
        this.div.style.position = "absolute";
        this.div.style.top = 0;
        this.div.style.bottom = 0;
        this.div.style.left = 0;
        this.div.style.right = 0;

        // Clear container and style it
        viewer.container.innerHTML = null;
        viewer.container.appendChild(this.holder);

        // Set width and height
        this.width  = this.div.offsetWidth;
        this.height = this.div.offsetHeight;

        var viewport = this;
        document.addEventListener("keydown", function(event){ 
          viewport.onkeydown(event)
        });
        document.addEventListener("keyup", function(event){ 
          viewport.onkeyup(event)
        });

        window.addEventListener("resize",    function(event){ viewport.onwindowresize(event) });

        // Add buttons
        this.addButtons();

        // Create canvas for renderer
        this.canvas = document.createElement("div");
        this.canvas.viewport = this;
        this.div.appendChild(this.canvas);

        // Bind events
        this.canvas.addEventListener("mousemove", function(event){ this.viewport.onmousemove(event)   });
        this.canvas.addEventListener("mousedown", function(event){ this.viewport.onmousedown(event)   });
        this.canvas.addEventListener("mouseup",   function(event){ this.viewport.onmouseup(event)     });
        this.canvas.addEventListener("wheel",     function(event){ this.viewport.onmousescroll(event) });
        this.canvas.addEventListener("mouseover", function(event){ this.viewport.onmouseover(event)   });
        this.canvas.addEventListener("mouseout",  function(event){ this.viewport.onmouseout(event)    });

        // Create selection info div
        this.hover_info = new R3JS.HoverInfo();
        this.div.appendChild( this.hover_info.div );

        // Add placeholder
        this.placeholder = document.createElement("div");
        this.placeholder.classList.add("viewport-placeholder");
        this.placeholder.innerHTML = this.placeholderContent;
        this.div.appendChild(this.placeholder);

    }


    // Get width and height
    getWidth(){
        return(this.div.offsetWidth);
    }

    getHeight(){
        return(this.div.offsetHeight);
    }

    getAspect(){
        return(this.getHeight() / this.getWidth());
    }

    hidePlaceholder(){
        this.canvas.style.display = null;
        this.placeholder.style.display = "none";
    }

    showPlaceholder(){
        this.canvas.style.display = "none";
        this.placeholder.style.display = null;
    }

}
R3JS.Viewport.prototype.placeholderContent = "Loading";



R3JS.HoverInfo = class HoverInfo{

    constructor(){

        this.div = document.createElement("div");
        this.div.id = "hover-info-div";

    }

    add(element){

        this.show();
        this.div.appendChild(element);

    }

    remove(element){

        this.div.removeChild(element);
        if(this.div.children.length === 0){
            this.hide();
        }

    }

    show(){ this.div.style.display = "block" }
    hide(){ this.div.style.display = "none"  }

}



