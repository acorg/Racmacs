

R3JS.apply_style = function(div, style){
    for(var i in style) {
        div.style[i] = style[i];
    }
}

function addLegend(viewport, plotData){

    var legend   = plotData.legend;

    // Create legend div
    var legend_div = document.createElement( 'div' );
    apply_style(legend_div, legend.style);
    viewport.appendChild(legend_div);

    // Create a legend title
    if(legend.title){
        var legend_title = document.createElement( 'div' );
        legend_div.appendChild(legend_title);
        legend_title.innerHTML = legend.title.name;
        apply_style(legend_title, legend.title.style);
    }
    
    for(var i=0; i<legend.items.length; i++){

        // Add to the legend
        addLegendLine(legend.items[i], legend_div);
    }

}


function addLegendLine(legend_data, legend_div){

    // Create a legend line
    var legend_line = document.createElement( 'div' );
    legend_div.appendChild(legend_line);
    apply_style(legend_line, legend_data.style);

    var width  = "15px";
    var height = "15px";

    // Create div for legend point
    var legend_point = document.createElement( 'div' );
    legend_line.appendChild(legend_point);
    legend_point.style.display = "inline-block";
    legend_point.style.width  = width;
    legend_point.style.height = height;
    legend_point.style.lineHeight = height;
    legend_point.style.verticalAlign = "middle";
    legend_point.style.backgroundColor = legend_data.fill;
    // renderLegendPoint(legend_point, point_object);  

    // Create div for legend description
    var legend_description = document.createElement( 'div' );
    legend_description.style.display = "inline-block";
    legend_description.style.lineHeight = height;
    legend_description.style.height = height;
    legend_description.style.verticalAlign = "middle";
    legend_description.style.paddingLeft  = "6px";
    legend_description.style.paddingRight = "12px";
    legend_description.style.fontSize = "80%";
    legend_description.innerHTML = legend_data.legend;
    legend_line.appendChild(legend_description);

}


function renderLegendPoint(element, point_object){

    // Create scene
    var scene  = new THREE.Scene();
    scene.background = new THREE.Color("#ffffff");
    var width  = element.offsetWidth / element.offsetHeight;
    var height = 1;

    if(point_object.properties.dimensions == 3){
        // Add ambient light
        var ambient_light = new THREE.AmbientLight( 0x404040 );
        scene.add( ambient_light );

        // Position light
        var light = new THREE.DirectionalLight(0xe0e0e0);
        light.position.set(-1,1,1).normalize();
        light.intensity = 1.0;
        scene.add( light );
    } else {
        // Add ambient light
        var ambient_light = new THREE.AmbientLight( 0xffffff );
        scene.add( ambient_light );
    }

    // Create camera
    var camera = new THREE.OrthographicCamera( width / - 2, width / 2, height / 2, height / - 2, 1, 1000 );
    camera.position.z = 5;

    // Create renderer
    var renderer = new THREE.WebGLRenderer({
        antialias: true,
        alpha: true
    });
    renderer.setSize( element.offsetWidth, element.offsetHeight );
    renderer.setPixelRatio( window.devicePixelRatio );

    // Add object to scene
    if(!point_object.properties.dimensions){
        point_object.properties.dimensions = 3
    }
    // point_object.lims     = plotData.lims;
    // point_object.aspect   = plotData.aspect;
    // point_object.viewport = viewport;
    var object = make_object(point_object);
    scene.add(object);
    
    // Add renderer to legend div
    element.appendChild(renderer.domElement);
    renderer.render( scene, camera );

}
