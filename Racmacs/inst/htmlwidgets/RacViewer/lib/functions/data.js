

Racmacs.Data = class Data {

    // Constructor
    constructor(viewer){

        // Bind to viewer
        viewer.data = this;
        this.viewer = viewer;

    }

    // Load new data
    load(data){
        this.data = data;
    }
    
    // Chart attributes
    tableName(){
        if(!this.data){ return("") }
        return(this.data.table_name);
    }

    numProjections(){
        if(!this.data || !this.data.optimizations){ return(0) }
        return(this.data.optimizations.length);
    }

    setProjection(num){
        this.data.selected_optimization = num;
    }

    // Selected projection
    projection(num){
        if(!this.data){ return(0) }
        if(this.data.selected_optimization == null){
            return(0)
        }
        if(typeof(num) === "undefined"){
            return(this.data.selected_optimization);
        } else {
            return(num);
        }
    }

    numAntigens(){
        if(!this.data){ return(0) }
        return(this.data.ag_names.length);
    }

    numSera(){
        if(!this.data){ return(0) }
        return(this.data.sr_names.length);
    }

    table(){
        return(this.data.table.slice(0));
    }

    // Projection attributes
    stress(num){
        var pnum = this.projection(num);
        return(this.data.optimizations[pnum].stress);
    }

    dimensions(num){
        var pnum = this.projection(num);
        if(!this.data || !this.data.optimizations || !this.data.optimizations[pnum]){ return(2) }
        return(this.data.optimizations[pnum].dimensions);
    }

    minColBasis(num){
        var pnum = this.projection(num);
        return(this.data.optimizations[pnum].minimum_column_basis);
    }

    agCoords(i){
        var pnum = this.projection();
        if(this.numProjections() == 0
            || !this.data.optimizations
            || !this.data.optimizations[pnum].ag_coords){
            return([0,0,0]);
        }
        return(this.data.optimizations[pnum].ag_coords[i].slice(0));
    }
    set_agCoords(i, coords){
        var pnum = this.projection();
        this.data.optimizations[pnum].ag_coords[i] = coords;
    }

    srCoords(i){
        if(this.numProjections() == 0){
            return([0,0,0]);
        }
        var pnum = this.projection();
        return(this.data.optimizations[pnum].sr_coords[i].slice(0));
    }
    set_srCoords(i, coords){
        var pnum = this.projection();
        this.data.optimizations[pnum].sr_coords[i] = coords;
    }

    table(){
        if(!this.data){ return([]) }
        return(this.data.table);
    }
    
    colbases(i){ 
        if(this.numProjections() == 0){
            return(0);
        }
        var pnum = this.projection();
        return(this.data.optimizations[pnum].colbases[i]) ;
    }
    

    // Plotspec
    agNames(i){ 
        if(!this.data){ return([]) }
        return(this.data.ag_names[i])
    }
    agSize(i){ 
        if(!this.data.ag_size) return(1);
        return(this.data.ag_size[i]);
    }
    agFill(i){ 
        if(!this.data.ag_cols_fill) return("green");
        return(this.data.ag_cols_fill[i]);
    }
    agOutline(i){ 
        if(!this.data.ag_cols_outline) return("black");
        return(this.data.ag_cols_outline[i])
    }
    agOutlineWidth(i){ 
        if(!this.data.ag_outline_width) return(1);
        return(this.data.ag_outline_width[i])
    }
    agAspect(i){ 
        if(!this.data.ag_aspect) return(1);
        return(this.data.ag_aspect[i])
    }
    agShape(i){ 
        if(!this.data.ag_shape) return("CIRCLE");
        return(this.data.ag_shape[i])
    }
    agDrawingOrder(i){ 
        if(!this.data.ag_drawing_order) return(1);
        return(this.data.ag_drawing_order[i])
    }
    srNames(i){ 
        return(this.data.sr_names[i])
    }
    srSize(i){ 
        if(!this.data.sr_size) return(1);
        return(this.data.sr_size[i])
    }
    srFill(i){ 
        return(this.data.sr_cols_fill[i])
    }
    srOutline(i){ 
        return(this.data.sr_cols_outline[i])
    }
    srOutlineWidth(i){ 
        if(!this.data.sr_outline_width) return(1);
        return(this.data.sr_outline_width[i])
    }
    srAspect(i){ 
        if(!this.data.sr_aspect) return(1);
        return(this.data.sr_aspect[i])
    }
    srShape(i){ 
        if(!this.data.sr_shape) return("BOX");
        return(this.data.sr_shape[i])
    }
    srDrawingOrder(i){ 
        if(!this.data.sr_drawing_order) return(1);
        return(this.data.sr_drawing_order[i])
    }



    // Diagnostics
    stressBlobs(num){
        var pnum = this.projection(num);
        if(!this.data.diagnostics
            || !this.data.diagnostics[pnum]
            || !this.data.diagnostics[pnum].stress_blobs){ 
            return(null) 
        } else {
            return(this.data.diagnostics[pnum].stress_blobs)
        }
    }

    hemisphering(num){
        var pnum = this.projection(num);
        if(!this.data.diagnostics
            || !this.data.diagnostics[pnum]
            || !this.data.diagnostics[pnum].hemisphering){ 
            return(null) 
        } else {
            return(this.data.diagnostics[pnum].hemisphering)
        }
    }

    // Procrustes
    procrustes(num){
        var pnum = this.projection(num);
        if(!this.data.procrustes
            || !this.data.procrustes[pnum]){ 
            return(null) 
        } else {
            return(this.data.procrustes[pnum])
        }
    }


}

