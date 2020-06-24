

Racmacs.Data = class Data {

    // Constructor
    constructor(viewer){

        // Bind to viewer
        viewer.data = this;
        this.viewer = viewer;

    }

    // Clear data
    clear(){
        this.data = null;
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
        let tabledata;

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

    logtable(){
        return(Racmacs.utils.logTiters(this.table()));
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
        if(this.data.c.P.length == 0) return(null)
        let pnum = this.projection();
        if(this.data.c.x.transformation && this.data.c.x.transformation[pnum]){
            return(this.data.c.x.transformation[pnum]);
        } else {
            if(this.data.c.P[pnum].t !== undefined){
                return(this.data.c.P[pnum].t);
            } else {
                var dim = this.dimensions(pnum);
                var transform = new Array(dim*dim).fill(0);
                if(dim == 2){
                    transform[0] = 1;
                    transform[3] = 1;
                }
                if(dim == 3){
                    transform[0] = 1;
                    transform[4] = 1;
                    transform[8] = 1;
                }
                return(transform);
            }
        }
    }

    translation(){
        let pnum = this.projection();
        if(this.data.c.x.transformation && this.data.c.x.translation && this.data.c.x.translation[pnum]){
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
        if(this.data.c.P.length == 0) return(null)
        let pnum = this.projection(num);
        return(
            Math.max(...this.data.c.P[pnum].l.map( p => p.length ))
        );
    }

    minColBasis(num){
        // let pnum = this.projection(num);
        // return(this.data.optimizations[pnum].minimum_column_basis);
        return("none");
    }

    transformedCoords(){
        let pnum           = this.projection();
        let coords         = this.data.c.P[pnum].l.slice();
        return(this.transformCoords(coords));
    }

    transformCoords(coords){
        let transformation = this.transformation();
        let translation    = this.translation()
        return(
            coords.map(
                coord => Racmacs.utils.transformTranslateCoords(
                    coord,
                    transformation,
                    translation
                )
            )
        )
    }

    agBaseCoords(i){
        if(this.data.c.P.length == 0) return(null)
        let pnum = this.projection();
        return(this.data.c.P[pnum].l[i].slice());
    }

    agCoords(i){
        if(this.data.c.P.length == 0) return(null)
        return(
            Racmacs.utils.transformTranslateCoords(
                this.agBaseCoords(i),
                this.transformation(),
                this.translation()
            )
        )
    }

    agSequences(i){
        if(this.data.c.x.antigen_sequences){
            if(i === undefined) return(this.data.c.x.antigen_sequences);
            else                return(this.data.c.x.antigen_sequences[i]);
        } else {
            return(null);
        }
    }

    set_agCoords(i, coords){
        let pnum = this.projection();
        this.data.c.P[pnum].l[i] = coords;
    }

    srBaseCoords(i){
        if(this.data.c.P.length == 0) return(null)
        let pnum = this.projection();
        return(this.data.c.P[pnum].l[i + this.numAntigens()].slice());
    }

    srCoords(i){
        if(this.data.c.P.length == 0) return(null)
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
    
    colbases(i=null){ 
        if(this.numProjections() == 0){
            return(
                Racmacs.utils.calcColBases({
                    titers: this.table(),
                    mincolbasis: "none"
                })
            );
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

        if(i === null){
            return(colbases);
        } else {
            return(colbases[i]);
        }
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

    agShown(i){ 
        return(this.agPlotspec(i, "+", true));
    }
    srShown(i){
        return(this.srPlotspec(i, "+", true));
    }

    agSize(i){ 
        return(this.agPlotspec(i, "s", 5));
    }
    srSize(i){ 
        return(this.srPlotspec(i, "s", 5));
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
        return(this.agPlotspec(i, "o", 1)*1);
    }
    srOutlineWidth(i){ 
        return(this.srPlotspec(i, "o", 1)*1);
    }

    agAspect(i){ 
        return(this.agPlotspec(i, "a", 1));
    }
    srAspect(i){ 
        return(this.srPlotspec(i, "a", 1));
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

    // Bootstrap data
    bootstrap(){
        return(this.data.c.x.bootstrap);
    }

    // Procrustes data
    procrustes(){
        return(this.data.procrustes);
    }

    // Output the ace format
    outputAce(){
        return(JSON.stringify(this.data));
    }

    // Fetch viewer settings
    getViewerSetting(setting){
        return(null)
    }

    xlim(){
        var lim = this.getViewerSetting("xlim");
        if(lim === null){
            var coords = this.transformedCoords().map( x => isNaN(x[0]) ? 0 : x[0] );
            lim = [
                Math.min(...coords) - 1,
                Math.max(...coords) + 1,
            ];
        }
        return(lim);
    }

    ylim(){
        var lim = this.getViewerSetting("ylim");
        if(lim === null){
            var coords = this.transformedCoords().map( x => isNaN(x[1]) ? 0 : x[1] );
            lim = [
                Math.min(...coords) - 1,
                Math.max(...coords) + 1,
            ];
        }
        return(lim);
    }

    zlim(){
        var lim = this.getViewerSetting("zlim");
        if(lim === null){
            var coords = this.transformedCoords().map( x => isNaN(x[2]) ? 0 : x[2] );
            lim = [
                Math.min(...coords) - 1,
                Math.max(...coords) + 1,
            ];
        }
        return(lim);
    }

}

