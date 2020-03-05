

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

        let table;

        // If table data provided as a list of objects
        if(this.data.c.t.d){

            // Setup table
            table = Array(this.data.c.a.length);
            for(let i=0; i<this.data.c.a.length; i++){
                table[i] = Array(this.data.c.s.length).fill("*");
            }

            // Fill in table from json data
            tabledata = this.data.c.t.d;
            for(let i=0; i<tabledata.length; i++){
                for (let [key, value] of Object.entries(tabledata[i])) {
                  table[i][Number(key)] = value;
                }
            }

        } 
        // If table data provided as a list of lists
        else {

            // Simply return the array
            table = this.data.c.t.l;

        }
        
        // Return the table data
        return(table);

    }

    // Projection attributes
    stress(num){
        let pnum = this.projection(num);
        if(this.data.c.P[pnum].s){
          return(this.data.c.P[pnum].s);
        } else {
          return(0);
        }
    }

    transformation(){
        let pnum = this.projection();
        if(this.data.c.x.transformation[pnum]){
            return(this.data.c.x.transformation[pnum]);
        } else {
            return(this.data.c.P[pnum].t);
        }
    }

    translation(){
        let pnum = this.projection();
        if(this.data.c.x.translation[pnum]){
            return(this.data.c.x.translation[pnum]);
        } else {
            return(new Array(this.dimensions(pnum)).fill(0));
        }
    }

    setTransformation(t, num){
        raise("cannot set transformation");
        // let pnum = this.projection(num);
        // if(!this.data.c.x) this.data.c.x = {};
        // if(!this.data.c.x.transformation) this.data.c.x.transformation = [];
        // while(this.data.c.x.transformation.length < pnum - 1) this.data.c.x.transformation.push([]);
        // this.data.c.x.transformation[pnum] = t;
    }

    dimensions(num){
        let pnum = this.projection(num);
        return(this.data.c.P[pnum].l[0].length);
    }

    minColBasis(num){
        // let pnum = this.projection(num);
        // return(this.data.optimizations[pnum].minimum_column_basis);
        return("none");
    }

    agBaseCoords(i){
        let pnum = this.projection();
        return(this.data.c.P[pnum].l[i].slice());
    }

    agCoords(i){
        return(
            Racmacs.utils.transformTranslateCoords(
                this.agBaseCoords(i),
                this.transformation(),
                this.translation()
            )
        )
    }

    set_agCoords(i, coords){
        let pnum = this.projection();
        this.data.c.P[pnum].l[i] = coords;
    }

    srBaseCoords(i){
        let pnum = this.projection();
        return(this.data.c.P[pnum].l[i + this.numAntigens()].slice());
    }

    srCoords(i){
        return(
            Racmacs.utils.transformTranslateCoords(
                this.srBaseCoords(i),
                this.transformation(),
                this.translation()
            )
        );
    }

    set_srCoords(i, coords){
        let pnum = this.projection();
        this.data.c.P[pnum].l[i + this.numAntigens()] = coords;
    }
    
    colbases(i){ 
        if(this.numProjections() == 0){
            return(0);
        }
        
        let pnum = this.projection();
        let colbases;
        let mincolbasis;

        if(this.data.c.P[pnum].C){
            // Forced column bases
            colbases = this.data.c.P[pnum].C;
        } else {
            // Minimum column bases
            if(this.data.c.P[pnum].m){
                mincolbasis = this.data.c.P[pnum].m;
            } else {
                mincolbasis = "none";
            }
            colbases = Racmacs.utils.calcColBases({
                titers: this.table(),
                mincolbasis: mincolbasis
            });
        }
        return(colbases[i]);
    }
    

    // Plotspec
    agPlotspec(i, attribute, base){
        let value = this.data.c.p.P[this.data.c.p.p[i]][attribute];
        if(typeof(value) === "undefined"){ value = base }
        return(value);
    }

    srPlotspec(i, attribute, base){
        let value = this.data.c.p.P[this.data.c.p.p[i + this.numAntigens()]][attribute];
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
        return(this.agPlotspec(i, "s", 1));
    }
    srSize(i){ 
        return(this.srPlotspec(i, "s", 1));
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
        return(this.agPlotspec(i, "?", 1)*1);
    }
    srOutlineWidth(i){ 
        return(this.srPlotspec(i, "?", 1)*1);
    }

    agAspect(i){ 
        return(this.agPlotspec(i, "?", 1));
    }
    srAspect(i){ 
        return(this.srPlotspec(i, "?", 1));
    }

    agShape(i){
        let shape = this.agPlotspec(i, "S", "CIRCLE");
        return(shape);
    }
    srShape(i){ 
        return(this.srPlotspec(i, "S", "CIRCLE"));
    }

    agDrawingOrder(i){
        // let pt_order = 0;
        // while(i != this.data.c.p.d[pt_order]){
        //     pt_order++;
        // }
        // return(-pt_order);
    }
    srDrawingOrder(i){ 
        // let pt_order = 0;
        // while(i+this.numAntigens() != this.data.c.p.d[pt_order]){
        //     pt_order++;
        // }
        // return(-pt_order);
    }

    ptDrawingOrder(){
        return(this.data.c.p.d);
    }



    // Diagnostics
    stressBlobs(num){
        let pnum = this.projection(num);
        if(!this.data.diagnostics
            || !this.data.diagnostics[pnum]
            || !this.data.diagnostics[pnum].stress_blobs){ 
            return(null) 
        } else {
            return(this.data.diagnostics[pnum].stress_blobs)
        }
    }

    hemisphering(num){
        let pnum = this.projection(num);
        if(!this.data.diagnostics
            || !this.data.diagnostics[pnum]
            || !this.data.diagnostics[pnum].hemisphering){ 
            return(null) 
        } else {
            return(this.data.diagnostics[pnum].hemisphering)
        }
    }

    // Boostrap data
    bootstrap(){
        return(this.data.c.x.bootstrap);
    }

    // Procrustes data
    procrustes(){
        return(this.data.procrustes);
    }


}

