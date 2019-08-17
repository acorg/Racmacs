

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
        return(this.data.c.i.N);
    }

    numProjections(){
        if(!this.data){ return(0) }
        return(this.data.c.P.length);
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
        return(this.data.c.a.length);
    }

    numSera(){
        if(!this.data){ return(0) }
        return(this.data.c.s.length);
    }

    table(){

        // Setup table
        var table = Array(this.data.c.a.length);
        for(var i=0; i<this.data.c.a.length; i++){
            table[i] = Array(this.data.c.s.length).fill("*");
        }

        // Fill in table from json data
        var tabledata = this.data.c.t.d;
        for(var i=0; i<tabledata.length; i++){
            for (let [key, value] of Object.entries(tabledata[i])) {
              table[i][Number(key)] = value;
            }
        }
        
        // Return the table data
        return(table);

    }

    // Projection attributes
    stress(num){
        var pnum = this.projection(num);
        return(this.data.c.P[pnum].s);
    }

    dimensions(num){
        var pnum = this.projection(num);
        return(this.data.c.P[pnum].l[0].length);
    }

    minColBasis(num){
        // var pnum = this.projection(num);
        // return(this.data.optimizations[pnum].minimum_column_basis);
        return("none");
    }

    agCoords(i){
        var pnum = this.projection();
        if(this.numProjections() == 0){
            return([0,0,0]);
        }
        return(this.data.c.P[pnum].l[i].slice(0));
    }
    set_agCoords(i, coords){
        var pnum = this.projection();
        this.data.c.P[pnum].l[i] = coords;
    }

    srCoords(i){
        var pnum = this.projection();
        if(this.numProjections() == 0){
            return([0,0,0]);
        }
        return(this.data.c.P[pnum].l[i + this.numAntigens()].slice(0));
    }
    set_srCoords(i, coords){
        var pnum = this.projection();
        this.data.c.P[pnum].l[i + this.numAntigens()] = coords;
    }
    
    colbases(i){ 
        if(this.numProjections() == 0){
            return(0);
        }
        var pnum = this.projection();
        return(this.data.c.P[pnum].C[i]) ;
    }
    

    // Plotspec
    agPlotspec(i, attribute, base){
        var value = this.data.c.p.P[this.data.c.p.p[i]][attribute];
        if(typeof(value) === "undefined"){ value = base }
        return(value);
    }

    srPlotspec(i, attribute, base){
        var value = this.data.c.p.P[this.data.c.p.p[i + this.numAntigens()]][attribute];
        if(typeof(value) === "undefined"){ value = base }
        return(value);
    }

    agNames(i){ 
        if(!this.data){ return([]) }
        return(this.data.c.a[i].N);
    }
    srNames(i){ 
        return(this.data.c.s[i].N);
    }

    agSize(i){ 
        return(this.agPlotspec(i, "s", 1)*6);
    }
    srSize(i){ 
        return(this.srPlotspec(i, "s", 1)*6);
    }

    agFill(i){ 
        return(this.agPlotspec(i, "F", "green"));
    }
    srFill(i){ 
        return(this.srPlotspec(i, "F", "transparent"));
    }

    agOutline(i){ 
        return(this.agPlotspec(i, "O", "black"));
    }
    srOutline(i){ 
        return(this.srPlotspec(i, "O", "black"));
    }

    agOutlineWidth(i){ 
        return(this.agPlotspec(i, "?", 1));
    }
    srOutlineWidth(i){ 
        return(this.srPlotspec(i, "?", 1));
    }

    agAspect(i){ 
        return(this.agPlotspec(i, "?", 1));
    }
    srAspect(i){ 
        return(this.srPlotspec(i, "?", 1));
    }

    agShape(i){ 
        return(this.agPlotspec(i, "S", "CIRCLE"));
    }
    srShape(i){ 
        return(this.srPlotspec(i, "S", "CIRCLE"));
    }

    agDrawingOrder(i){ 
        return(this.data.c.p.d[i]);
    }
    srDrawingOrder(i){ 
        return(this.data.c.p.d[i + this.numAntigens()]);
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

    // Boostrap data
    bootstrap(){
        return(this.data.bootstrap);
    }


}

