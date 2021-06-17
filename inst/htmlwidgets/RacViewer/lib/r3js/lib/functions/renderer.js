
R3JS.Renderer = class Renderer {

    constructor(){

        // Add WebGL renderer
        this.webglrenderer = new THREE.WebGLRenderer({
            antialias: true,
            alpha: true
        });
        var gl = this.webglrenderer.getContext();
        this.maxPointSize = gl.getParameter(gl.ALIASED_POINT_SIZE_RANGE)[1];
        this.webglrenderer.localClippingEnabled = true;
        this.webglrenderer.setPixelRatio( window.devicePixelRatio );

        // Add label renderer
        this.labelrenderer = new THREE.CSS2DRenderer();
        this.labelrenderer.domElement.style.position = 'absolute';
        this.labelrenderer.domElement.style.top = '0';
        this.labelrenderer.domElement.style.pointerEvents = 'none';

        // Setup for shaders
        this.shaders = {};

    }

    attachToViewport(viewport){
        viewport.canvas.appendChild(this.webglrenderer.domElement);
        viewport.canvas.appendChild(this.labelrenderer.domElement);
    }

    setSize(width, height){
        this.webglrenderer.setSize( width, height );
        this.labelrenderer.setSize( width, height );
    }

    render(scene, camera){
        this.webglrenderer.render( scene.scene, camera.camera );
        this.labelrenderer.render( scene.scene, camera.camera );
    }

    getPixelRatio(){
        return(this.webglrenderer.getPixelRatio());
    }

    setShaders(vertexShader, fragmentShader){
        this.shaders.vertexShader   = vertexShader;
        this.shaders.fragmentShader = fragmentShader;
    }

}



R3JS.SVGRenderer = class SVGRenderer {

    constructor(){

        // Add SVG renderer
        this.svgrenderer = new THREE.SVGRenderer();
        this.svgrenderer.setQuality("low");
        
        // Add label renderer
        this.labelrenderer = new THREE.CSS2DRenderer();
        this.labelrenderer.domElement.style.position = 'absolute';
        this.labelrenderer.domElement.style.top = '0';
        this.labelrenderer.domElement.style.pointerEvents = 'none';

        // Setup for shaders
        this.shaders = {};

    }

    attachToViewport(viewport){
        viewport.canvas.appendChild(this.svgrenderer.domElement);
        viewport.canvas.appendChild(this.labelrenderer.domElement);
    }

    setSize(width, height){
        this.svgrenderer.setSize( width, height );
        this.labelrenderer.setSize( width, height );
    }

    render(scene, camera){
        this.svgrenderer.render( scene.scene, camera.camera );
        this.labelrenderer.render( scene.scene, camera.camera );
    }

    getPixelRatio(){
        return(1);
    }

}


