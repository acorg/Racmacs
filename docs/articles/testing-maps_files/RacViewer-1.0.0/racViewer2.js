
function racViewer(container, mapData, settings){


    // Clear container and style it
    container.innerHTML = null;
    var in_iframe = !window==window.top;



    // Set default settings
    if(settings == null){
      settings = {}
    }
    var assign_defaultsetting = function(
        setting_name,
        setting_val
    ){
        if(!settings[setting_name]) { 
          settings[setting_name] = setting_val 
        }
    }

    if(settings.selectable == null){ 
      if(settings.controls) { settings.selectable = settings.controls  }
      else                  { settings.selectable = !in_iframe         }
    }
    if(settings.controls == null){ settings.controls = !in_iframe }



    // Generate the viewer and viewport
    var viewer   = build_viewer(container);
    var viewport = viewer.viewport;

    // Add viewport variables
    viewport.viewer = viewer;
    viewport.intersected = null;
    viewport.dragmode = false;
    viewport.damper = {};
    viewport.raytrace = true;
    viewport.labels = [];
    viewport.size = new THREE.Vector2(viewport.offsetWidth, viewport.offsetHeight);

    // Bind event listeners
    add_event_listeners(viewport);

    // Add buttons
    addButtons(viewport);

    // Add controls
    if(settings.selectable){
      bind_selectionFns(viewer);
    }

    // Add functions for selection of points
    if(settings.controls) {
      add_controls(viewer);
    }


    // Add WebGL renderer
    var renderer = new THREE.WebGLRenderer({
      antialias : true,
      alpha     : true
    });
    renderer.setPixelRatio( window.devicePixelRatio );
    renderer.setSize( viewport.offsetWidth, viewport.offsetHeight);
    viewport.renderer = renderer;
    viewport.appendChild(renderer.domElement);

    labelRenderer = new THREE.CSS2DRenderer();
    labelRenderer.setSize( viewport.offsetWidth, viewport.offsetHeight);
    viewport.labelRenderer = labelRenderer;
    labelRenderer.domElement.style.position = 'absolute';
    labelRenderer.domElement.style.top = '0';
    labelRenderer.domElement.style.pointerEvents = 'none';
    viewport.appendChild(labelRenderer.domElement);

    // Add raycaster
    addRaycaster(viewport);

    // Animate the scene
    viewport.animate = function() {
      if(viewport.mouse.over || viewport.touch.num > 0 || viewport.damper.running){
        if(!viewport.mouse.down && viewport.raytrace){
          viewport.raytrace();
        }
        viewport.render();
      }
      viewport.animationFrame = requestAnimationFrame(viewport.animate);
    }

    // Bind API functions
    bindAPI(viewer);

    // Bind navigation functions
    bind_navigation(viewport, mapData.dimensions);

    // Bind and execute the data loading functions
    bindViewerLoadFn(viewer);
    viewer.load(mapData);



    return(viewer);

    // assign_defaultsetting("relax_steps_max",     1000);
    // assign_defaultsetting("relax_min_reduction", 0.02);
    // assign_defaultsetting("relax_min_reduction", 0.02);


    
    // // Add viewer variables
    // viewer.settings = settings;
    // viewer.relax_steps_max = 1000;
    // viewer.relax_min_reduction = 0.02;
    // viewer.connectionLines = false;
    // viewer.errorLines = false;
    // viewer.dragMode = false;
    // viewer.relax_on = false;
    // viewer.container = container;
    // viewer.settings = settings;
  

}

