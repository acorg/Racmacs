
R3JS.Shaders = {};
R3JS.Shaders.VertexShader2D = `

    attribute float size;
	attribute float shape;
	attribute vec4 fillColor;
	attribute vec4 outlineColor;
	attribute float outlineWidth;
	attribute float fillAlpha;
	//attribute float outlineAlpha;
	attribute float aspect;
	attribute float visible;
	
	varying vec4 pFillColor;
	varying vec4 pOutlineColor;
	//varying float pOutlineAlpha;
	varying float pOutlineWidth;
	varying float pSize;
	varying float pAspect;
	varying float pScale;
	varying float pShape;
	varying float pVisible;
	varying float pPixelRatio;
	varying vec2 screenpos;
	
	uniform float scale;
	uniform float viewportHeight;
	uniform float viewportWidth;
	uniform float viewportPixelRatio;

	void main() {
		
		pFillColor    = fillColor;
		pOutlineColor = outlineColor;
		//pOutlineAlpha = outlineAlpha;
	    pVisible      = visible;
		pAspect       = aspect;
	    pSize         = size;
	    pShape        = shape;
	    pOutlineWidth = outlineWidth;
	    pPixelRatio   = viewportPixelRatio;

		vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
		gl_Position = projectionMatrix * mvPosition;
		screenpos     = vec2(gl_Position[0], gl_Position[1]);

		pScale       = pSize*scale*(viewportHeight/20.0)*pPixelRatio;
		gl_PointSize = pScale;
        
        if(gl_Position[0] < 0.0){
		    gl_Position[0] = gl_Position[0] + gl_PointSize*0.5/(viewportWidth*viewportPixelRatio)*gl_Position[3];
	    } else {
	    	gl_Position[0] = gl_Position[0] - gl_PointSize*0.5/(viewportWidth*viewportPixelRatio)*gl_Position[3];
	    }

	    if(gl_Position[1] < 0.0){
		    gl_Position[1] = gl_Position[1] + gl_PointSize*0.5/(viewportHeight*viewportPixelRatio)*gl_Position[3];
		} else {
			gl_Position[1] = gl_Position[1] - gl_PointSize*0.5/(viewportHeight*viewportPixelRatio)*gl_Position[3];
		}


	}

`;

R3JS.Shaders.VertexShader3D = `

	attribute float size;
	attribute float shape;
	attribute vec4 fillColor;
	attribute vec4 outlineColor;
	attribute float outlineWidth;
	attribute float fillAlpha;
	//attribute float outlineAlpha;
	attribute float aspect;
	attribute float visible;
	
	varying vec4 pFillColor;
	varying vec4 pOutlineColor;
	//varying float pOutlineAlpha;
	varying float pOutlineWidth;
	varying float pSize;
	varying float pAspect;
	varying float pScale;
	varying float pShape;
	varying float pPixelRatio;
	varying float pVisible;
	varying vec2 screenpos;
	
	uniform float scale;
	uniform float viewportHeight;
	uniform float viewportWidth;
	uniform float viewportPixelRatio;

	void main() {
		
		pFillColor    = fillColor;
		pOutlineColor = outlineColor;
		//pOutlineAlpha = outlineAlpha;
		pAspect       = aspect;
	    pSize         = size;
	    pShape        = shape;
	    pOutlineWidth = outlineWidth;
	    pPixelRatio   = viewportPixelRatio;
	    pVisible      = visible;

		vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
		gl_Position = projectionMatrix * mvPosition;
		screenpos     = vec2(gl_Position[0], gl_Position[1]);

		pScale       = pSize*scale*(viewportHeight/1000.0)*pPixelRatio;
		pScale       = pScale*2.0 * ( 45.0 / -mvPosition.z );
		gl_PointSize = pScale;
        
        if(gl_Position[0] < 0.0){
		    gl_Position[0] = gl_Position[0] + gl_PointSize*0.5/(viewportWidth*viewportPixelRatio)*gl_Position[3];
	    } else {
	    	gl_Position[0] = gl_Position[0] - gl_PointSize*0.5/(viewportWidth*viewportPixelRatio)*gl_Position[3];
	    }

	    if(gl_Position[1] < 0.0){
		    gl_Position[1] = gl_Position[1] + gl_PointSize*0.5/(viewportHeight*viewportPixelRatio)*gl_Position[3];
		} else {
			gl_Position[1] = gl_Position[1] - gl_PointSize*0.5/(viewportHeight*viewportPixelRatio)*gl_Position[3];
		}


	}

`;








R3JS.Shaders.FragmentShader2D = `

	varying vec4  pFillColor;
    varying vec4  pOutlineColor;
    //varying float pOutlineAlpha;
    varying float pOutlineWidth;
	varying float pSize;
	varying float pShape;
	varying float pScale;
	varying float pAspect;
	varying float pVisible;
	varying float pPixelRatio;
	varying vec2 screenpos;

	uniform float opacity;

	void main() {

		// Discard if not visible
		if(pVisible == 0.0) discard;

		// Set variables to style and anti-alias points
	    float outline_width = (0.06/pSize)*pOutlineWidth;
	    float blend_range = 4.0/(pScale*pPixelRatio);
	    float fade_range  = 2.0/(pScale*pPixelRatio);
        
        // Tranform point coordinate
		vec2 p = gl_PointCoord;
        if(screenpos[0] < 0.0){
        	p[0] = (gl_PointCoord[0] - 0.25)*2.0;
        } else {
            p[0] = (gl_PointCoord[0] - 0.75)*2.0;
        }

        if(screenpos[1] < 0.0){
        	p[1] = (gl_PointCoord[1] - 0.75)*2.0;
        } else {
        	p[1] = (gl_PointCoord[1] - 0.25)*2.0;
        }

        // Transform for aspect
        p.x = p.x/pAspect;

        // Square
	    if(pShape == 1.0){

	        float lim = 0.5;
	        float apx = abs(p.x);
	        float apy = abs(p.y);
	        
	        if(apx > lim || apy > lim){
	            discard;
	        } else if(apx > lim-outline_width || apy > lim-outline_width){
	            if(pOutlineColor[3] == 0.0){
	            	discard;
	            } else {
	                gl_FragColor = pOutlineColor;
	            }
	        } else if(apx > lim-outline_width-blend_range || apy > lim-outline_width-blend_range){
	            if(apx > apy){
	                gl_FragColor = mix(pFillColor, pOutlineColor, (apx - (lim-outline_width-blend_range))/blend_range);
	            } else {
	                gl_FragColor = mix(pFillColor, pOutlineColor, (apy - (lim-outline_width-blend_range))/blend_range);
	            }
	        } else {
	        	if(pFillColor[3] == 0.0){
	            	discard;
	            } else {
	                gl_FragColor = pFillColor;
	            }
	        }
	        
	        if(apx > lim-fade_range || apy > lim-fade_range){
	            if(apx > apy){
	                gl_FragColor.a = gl_FragColor.a*(1.0-(apx-(lim-fade_range))/fade_range);
	            } else {
	                gl_FragColor.a = gl_FragColor.a*(1.0-(apy-(lim-fade_range))/fade_range);
	            }
	        }
	    }

	    // Triangle
	    if(pShape == 2.0){

		    vec2 p1 = vec2(0.3849,  0.1666);
			vec2 p2 = vec2(-0.3849, 0.1666);
			vec2 p3 = vec2(0,    -0.5);
	        
			float alpha = ((p2.y - p3.y)*(p.x - p3.x) + (p3.x - p2.x)*(p.y - p3.y)) /
			        ((p2.y - p3.y)*(p1.x - p3.x) + (p3.x - p2.x)*(p1.y - p3.y));
			float beta = ((p3.y - p1.y)*(p.x - p3.x) + (p1.x - p3.x)*(p.y - p3.y)) /
			       ((p2.y - p3.y)*(p1.x - p3.x) + (p3.x - p2.x)*(p1.y - p3.y));
			float gamma = 1.0 - alpha - beta;
	        
	        if(alpha < 0.0 || beta < 0.0 || gamma < 0.0){
	            discard;
	        } else if(alpha < outline_width || beta < outline_width || gamma < outline_width){
			    if(pOutlineColor[3] == 0.0){
	            	discard;
	            } else {
	                gl_FragColor = pOutlineColor;
	            }
	        } else if(alpha < outline_width + blend_range || beta < outline_width + blend_range || gamma < outline_width + blend_range){
	            if(alpha < beta && alpha < gamma){
	                gl_FragColor = mix(pOutlineColor, pFillColor, (alpha-outline_width)/blend_range);
	            } else if(beta < gamma) {
	                gl_FragColor = mix(pOutlineColor, pFillColor, (beta-outline_width)/blend_range);
	            } else {
	                gl_FragColor = mix(pOutlineColor, pFillColor, (gamma-outline_width)/blend_range);
	            }
	        } else {
	            if(pFillColor[3] == 0.0){
	            	discard;
	            } else {
	                gl_FragColor = pFillColor;
	            }
	        }
	        
	        if(alpha < fade_range || beta < fade_range || gamma < fade_range){
	            if(alpha < beta && alpha < gamma){
	                gl_FragColor.a = gl_FragColor.a*(alpha/fade_range);
	            } else if(beta < gamma) {
	                gl_FragColor.a = gl_FragColor.a*(beta/fade_range);
	            } else {
	                gl_FragColor.a = gl_FragColor.a*(gamma/fade_range);
	            }
	        }

	    }

	    // Circle
	    if(pShape == 0.0){

	        float radius = 0.5;
	        float dist = sqrt(p.x * p.x + p.y * p.y);

	        if(dist > radius){
	            discard;
	        } else if(dist > radius - outline_width){
	            if(pOutlineColor[3] == 0.0){
	            	discard;
	            } else {
	                gl_FragColor = pOutlineColor;
	            }
	        } else if(dist > radius - outline_width - blend_range){
	            gl_FragColor = mix(pFillColor, pOutlineColor, (dist-(radius-outline_width-blend_range))/blend_range);
	        } else {
	            if(pFillColor[3] == 0.0){
	            	discard;
	            } else {
	                gl_FragColor = pFillColor;
	            }
	        }

	        if(dist > radius - fade_range){
	            gl_FragColor.a = gl_FragColor.a*(1.0-(dist - (radius - fade_range))/fade_range);
	        }

	    }


	}

`;




R3JS.Shaders.FragmentShader3D = `

	varying vec4  pFillColor;
    varying vec4  pOutlineColor;
    //varying float pOutlineAlpha;
    varying float pOutlineWidth;
	varying float pSize;
	varying float pShape;
	varying float pScale;
	varying float pAspect;
	varying vec2 screenpos;

	uniform float opacity;
	uniform sampler2D circleTexture;

	void main() {


		// Set variables to style and anti-alias points
	    float outline_width = (0.05/pSize)*pOutlineWidth;
	    float blend_range = (0.05/pScale);
	    float fade_range  = (0.1/pScale);
        
        // Tranform point coordinate
		vec2 p = gl_PointCoord;
        if(screenpos[0] < 0.0){
        	p[0] = (gl_PointCoord[0] - 0.25)*2.0;
        } else {
            p[0] = (gl_PointCoord[0] - 0.75)*2.0;
        }

        if(screenpos[1] < 0.0){
        	p[1] = (gl_PointCoord[1] - 0.75)*2.0;
        } else {
        	p[1] = (gl_PointCoord[1] - 0.25)*2.0;
        }
        
        // Sphere
        gl_FragColor = pFillColor * texture2D( circleTexture, vec2(p[0]+0.5, p[1]+0.5) );
        gl_FragColor.a = gl_FragColor.a = gl_FragColor.a;

	    float radius = 0.4;
        float dist = sqrt(p.x * p.x + p.y * p.y);

        if(dist > radius){
           discard;
        }

	}

`;


// Arrowhead ------------

R3JS.Shaders.VertexShaderArrowHead = `

    attribute float size;
	attribute vec4 fillColor;
	attribute vec4 outlineColor;
	attribute float outlineWidth;
	attribute float fillAlpha;
	//attribute float outlineAlpha;
	attribute float aspect;
	attribute float rotation;
	attribute float visible;
	
	varying vec4 pFillColor;
	varying vec4 pOutlineColor;
	//varying float pOutlineAlpha;
	varying float pOutlineWidth;
	varying float pSize;
	varying float pAspect;
	varying float pScale;
	varying float pVisible;
	varying float pPixelRatio;
	varying float pSceneRotation;
	varying float pRotation;
	varying vec2 screenpos;
	
	uniform float scale;
	uniform float viewportHeight;
	uniform float viewportWidth;
	uniform float viewportPixelRatio;
	uniform float sceneRotation;

	void main() {
		
		pFillColor      = fillColor;
		pOutlineColor   = outlineColor;
		//pOutlineAlpha = outlineAlpha;
	    pVisible        = visible;
		pAspect         = aspect;
	    pSize           = size;
	    pOutlineWidth   = outlineWidth;
	    pPixelRatio     = viewportPixelRatio;
	    pSceneRotation  = sceneRotation;
	    pRotation       = rotation;

		vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
		gl_Position = projectionMatrix * mvPosition;
		screenpos     = vec2(gl_Position[0], gl_Position[1]);

		pScale       = pSize*scale*(viewportHeight/20.0)*pPixelRatio;
		gl_PointSize = pScale;
        
        if(gl_Position[0] < 0.0){
		    gl_Position[0] = gl_Position[0] + gl_PointSize*0.5/(viewportWidth*viewportPixelRatio)*gl_Position[3];
	    } else {
	    	gl_Position[0] = gl_Position[0] - gl_PointSize*0.5/(viewportWidth*viewportPixelRatio)*gl_Position[3];
	    }

	    if(gl_Position[1] < 0.0){
		    gl_Position[1] = gl_Position[1] + gl_PointSize*0.5/(viewportHeight*viewportPixelRatio)*gl_Position[3];
		} else {
			gl_Position[1] = gl_Position[1] - gl_PointSize*0.5/(viewportHeight*viewportPixelRatio)*gl_Position[3];
		}


	}

`;


R3JS.Shaders.VertexShaderArrowStem = `
		
		#include <common>
		#include <color_pars_vertex>
		#include <fog_pars_vertex>
		#include <logdepthbuf_pars_vertex>
		#include <clipping_planes_pars_vertex>

		uniform float linewidth;
		uniform vec2 resolution;

		attribute vec3 instanceStart;
		attribute vec3 instanceEnd;

		attribute vec3 instanceColorStart;
		attribute vec3 instanceColorEnd;

		attribute float doubleHeaded;
		attribute float arrowheadlength;

		varying vec2 vUv;
		varying float linedist;
		varying float linedoubleHeaded;
		varying float linearrowheadlength;

		#ifdef USE_DASH

			uniform float dashScale;
			attribute float instanceDistanceStart;
			attribute float instanceDistanceEnd;
			varying float vLineDistance;

		#endif

		void trimSegment( const in vec4 start, inout vec4 end ) {

			// trim end segment so it terminates between the camera plane and the near plane

			// conservative estimate of the near plane
			float a = projectionMatrix[ 2 ][ 2 ]; // 3nd entry in 3th column
			float b = projectionMatrix[ 3 ][ 2 ]; // 3nd entry in 4th column
			float nearEstimate = - 0.5 * b / a;

			float alpha = ( nearEstimate - start.z ) / ( end.z - start.z );

			end.xyz = mix( start.xyz, end.xyz, alpha );

		}

		void main() {

			linedoubleHeaded = doubleHeaded;
			linearrowheadlength = arrowheadlength;

			#ifdef USE_COLOR

				vColor.xyz = ( position.y < 0.5 ) ? instanceColorStart : instanceColorEnd;

			#endif

			#ifdef USE_DASH

				vLineDistance = ( position.y < 0.5 ) ? dashScale * instanceDistanceStart : dashScale * instanceDistanceEnd;

			#endif

			float aspect = resolution.x / resolution.y;

			vUv = uv;

			// camera space
			vec4 start = modelViewMatrix * vec4( instanceStart, 1.0 );
			vec4 end = modelViewMatrix * vec4( instanceEnd, 1.0 );

			// special case for perspective projection, and segments that terminate either in, or behind, the camera plane
			// clearly the gpu firmware has a way of addressing this issue when projecting into ndc space
			// but we need to perform ndc-space calculations in the shader, so we must address this issue directly
			// perhaps there is a more elegant solution -- WestLangley

			bool perspective = ( projectionMatrix[ 2 ][ 3 ] == - 1.0 ); // 4th entry in the 3rd column

			if ( perspective ) {

				if ( start.z < 0.0 && end.z >= 0.0 ) {

					trimSegment( start, end );

				} else if ( end.z < 0.0 && start.z >= 0.0 ) {

					trimSegment( end, start );

				}

			}

			// clip space
			vec4 clipStart = projectionMatrix * start;
			vec4 clipEnd = projectionMatrix * end;

			// ndc space
			vec2 ndcStart = clipStart.xy / clipStart.w;
			vec2 ndcEnd = clipEnd.xy / clipEnd.w;

			// direction
			vec2 dir = ndcEnd - ndcStart;



			// Calculate line distance ----------
			
			vec2 ndcEndAsp   = vec2(ndcEnd);
			vec2 ndcStartAsp = vec2(ndcStart);
			ndcEndAsp.x *= aspect;
			ndcStartAsp.x *= aspect;

			linedist = distance(ndcEndAsp, ndcStartAsp);



			// account for clip-space aspect ratio
			dir.x *= aspect;
			dir = normalize( dir );

			// perpendicular to dir
			vec2 offset = vec2( dir.y, - dir.x );

			// undo aspect ratio adjustment
			dir.x /= aspect;
			offset.x /= aspect;

			// sign flip
			if ( position.x < 0.0 ) offset *= - 1.0;

			// endcaps
			if ( position.y < 0.0 ) {

				offset += - dir;

			} else if ( position.y > 1.0 ) {

				offset += dir;

			}

			// adjust for linewidth
			offset *= linewidth;

			// adjust for clip-space to screen-space conversion // maybe resolution should be based on viewport ...
			offset /= resolution.y;

			// select end
			vec4 clip = ( position.y < 0.5 ) ? clipStart : clipEnd;

			// back to clip space
			offset *= clip.w;

			clip.xy += offset;

			gl_Position = clip;

			vec4 mvPosition = ( position.y < 0.5 ) ? start : end; // this is an approximation

			#include <logdepthbuf_vertex>
			#include <clipping_planes_vertex>
			#include <fog_vertex>

		}
`;

R3JS.Shaders.FragmentShaderArrowStem = `

		uniform vec3 diffuse;
		uniform float opacity;

		#ifdef USE_DASH

			uniform float dashSize;
			uniform float gapSize;

		#endif

		varying float linedoubleHeaded;

		#include <common>
		#include <color_pars_fragment>
		#include <fog_pars_fragment>
		#include <logdepthbuf_pars_fragment>
		#include <clipping_planes_pars_fragment>

		varying vec2 vUv;
		varying float linedist;
		varying float linearrowheadlength;

		void main() {

			float linelengthmax = (linedist - linearrowheadlength) / linedist;
			float linelengthmin = ((linearrowheadlength) / linedist) - 1.0;
			float dist = vUv.y;

			if ( dist >= linelengthmax ){
				
				discard;

			}

			if ( linedoubleHeaded == 1.0 && dist <= linelengthmin ){

				discard;

			}

			#include <clipping_planes_fragment>

			#ifdef USE_DASH

				if ( vUv.y < - 1.0 || vUv.y > 1.0 ) discard; // discard endcaps

				if ( mod( vLineDistance, dashSize + gapSize ) > dashSize ) discard; // todo - FIX

			#endif

			if ( abs( vUv.y ) > 1.0 ) {

				float a = vUv.x;
				float b = ( vUv.y > 0.0 ) ? vUv.y - 1.0 : vUv.y + 1.0;
				float len2 = a * a + b * b;

				if ( len2 > 1.0 ) discard;

			}

			vec4 diffuseColor = vec4( diffuse, opacity );

			#include <logdepthbuf_fragment>
			#include <color_fragment>

			gl_FragColor = vec4( diffuseColor.rgb, diffuseColor.a );

			#include <premultiplied_alpha_fragment>
			#include <tonemapping_fragment>
			#include <encodings_fragment>
			#include <fog_fragment>

		}

`;









R3JS.Shaders.VertexShaderArrowHead = `

    attribute float size;
	attribute vec4 fillColor;
	attribute vec4 outlineColor;
	attribute float outlineWidth;
	attribute float fillAlpha;
	//attribute float outlineAlpha;
	attribute float aspect;
	attribute float rotation;
	attribute float visible;
	
	varying vec4 pFillColor;
	varying vec4 pOutlineColor;
	//varying float pOutlineAlpha;
	varying float pOutlineWidth;
	varying float pSize;
	varying float pAspect;
	varying float pScale;
	varying float pVisible;
	varying float pPixelRatio;
	varying float pSceneRotation;
	varying float pRotation;
	varying vec2 screenpos;
	
	uniform float scale;
	uniform float viewportHeight;
	uniform float viewportWidth;
	uniform float viewportPixelRatio;
	uniform float sceneRotation;

	void main() {
		
		pFillColor      = fillColor;
		pOutlineColor   = outlineColor;
		//pOutlineAlpha = outlineAlpha;
	    pVisible        = visible;
		pAspect         = aspect;
	    pSize           = size;
	    pOutlineWidth   = outlineWidth;
	    pPixelRatio     = viewportPixelRatio;
	    pSceneRotation  = sceneRotation;
	    pRotation       = rotation;

		vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
		gl_Position = projectionMatrix * mvPosition;
		screenpos     = vec2(gl_Position[0], gl_Position[1]);

		pScale       = pSize*scale*(viewportHeight/20.0)*pPixelRatio;
		gl_PointSize = pScale;
        
        if(gl_Position[0] < 0.0){
		    gl_Position[0] = gl_Position[0] + gl_PointSize*0.5/(viewportWidth*viewportPixelRatio)*gl_Position[3];
	    } else {
	    	gl_Position[0] = gl_Position[0] - gl_PointSize*0.5/(viewportWidth*viewportPixelRatio)*gl_Position[3];
	    }

	    if(gl_Position[1] < 0.0){
		    gl_Position[1] = gl_Position[1] + gl_PointSize*0.5/(viewportHeight*viewportPixelRatio)*gl_Position[3];
		} else {
			gl_Position[1] = gl_Position[1] - gl_PointSize*0.5/(viewportHeight*viewportPixelRatio)*gl_Position[3];
		}


	}

`;


R3JS.Shaders.FragmentShaderArrowHead = `

	varying vec4  pFillColor;
    varying vec4  pOutlineColor;
    //varying float pOutlineAlpha;
    varying float pOutlineWidth;
	varying float pSize;
	varying float pScale;
	varying float pAspect;
	varying float pVisible;
	varying float pPixelRatio;
	varying float pSceneRotation;
	varying float pRotation;
	varying vec2 screenpos;

	uniform float opacity;

	void main() {

		// Discard if not visible
		if(pVisible == 0.0) discard;

		// Set variables to style and anti-alias points
	    float outline_width = (0.06/pSize)*pOutlineWidth;
	    float blend_range = 4.0/(pScale*pPixelRatio);
	    float fade_range  = 10.0/(pScale*pPixelRatio);
        
        // Tranform point coordinate
		vec2 p = gl_PointCoord;
        if(screenpos[0] < 0.0){
        	p[0] = (gl_PointCoord[0] - 0.25)*2.0;
        } else {
            p[0] = (gl_PointCoord[0] - 0.75)*2.0;
        }

        if(screenpos[1] < 0.0){
        	p[1] = (gl_PointCoord[1] - 0.75)*2.0;
        } else {
        	p[1] = (gl_PointCoord[1] - 0.25)*2.0;
        }


        // Transform for rotation
        float xo = p.x;
        float yo = p.y;
        float totalRotation = pRotation + pSceneRotation;
        p.x = xo*cos(totalRotation) - yo*sin(totalRotation);
        p.y = xo*sin(totalRotation) + yo*cos(totalRotation);

        // Triangle
        vec2 p1 = vec2(0.25,  0.25);
		vec2 p2 = vec2(-0.25, 0.25);
		vec2 p3 = vec2(0,    0);

        // Transform for aspect
        p1.x = p1.x*pAspect;
        p2.x = p2.x*pAspect;
        p3.x = p3.x*pAspect;
	 
        
		float alpha = ((p2.y - p3.y)*(p.x - p3.x) + (p3.x - p2.x)*(p.y - p3.y)) /
		        ((p2.y - p3.y)*(p1.x - p3.x) + (p3.x - p2.x)*(p1.y - p3.y));
		float beta = ((p3.y - p1.y)*(p.x - p3.x) + (p1.x - p3.x)*(p.y - p3.y)) /
		       ((p2.y - p3.y)*(p1.x - p3.x) + (p3.x - p2.x)*(p1.y - p3.y));
		float gamma = 1.0 - alpha - beta;
        
        if(alpha < 0.0 || beta < 0.0 || gamma < 0.0){
            discard;
        } else if(alpha < outline_width || beta < outline_width || gamma < outline_width){
		    if(pOutlineColor[3] == 0.0){
            	discard;
            } else {
                gl_FragColor = pOutlineColor;
            }
        } else if(alpha < outline_width + blend_range || beta < outline_width + blend_range || gamma < outline_width + blend_range){
            if(alpha < beta && alpha < gamma){
                gl_FragColor = mix(pOutlineColor, pFillColor, (alpha-outline_width)/blend_range);
            } else if(beta < gamma) {
                gl_FragColor = mix(pOutlineColor, pFillColor, (beta-outline_width)/blend_range);
            } else {
                gl_FragColor = mix(pOutlineColor, pFillColor, (gamma-outline_width)/blend_range);
            }
        } else {
            if(pFillColor[3] == 0.0){
            	discard;
            } else {
                gl_FragColor = pFillColor;
            }
        }
        
        if(alpha < fade_range || beta < fade_range || gamma < fade_range){
            if(alpha < beta && alpha < gamma){
                gl_FragColor.a = gl_FragColor.a*(alpha/fade_range);
            } else if(beta < gamma) {
                gl_FragColor.a = gl_FragColor.a*(beta/fade_range);
            } else {
                gl_FragColor.a = gl_FragColor.a*(gamma/fade_range);
            }
        }

	}

`;

// // Line shaders
// function get_lineVertex_shader(){
    
//     return(`
    	
//     	uniform float amplitude;
// 		attribute float visible;
// 		// varying vec3 color;
// 		void main() {
// 			if(visible != 0.0){
// 			    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
// 		    }
// 		}

//     `);

// }

// function get_lineFragment_shader(){

//     return(`
// 		// uniform vec3 color;
// 		// uniform float opacity;
// 		// varying vec3 vColor;
// 		void main() {
// 			gl_FragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
// 		}
// 	`);

// }






