

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
        if(typeof(num) === "undefined"){
            if(this.data.selected_optimization == null){
                return(0);
            }
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

    transformation(num){
        if(this.data.c.P.length == 0) return(null)
        let pnum = this.projection(num);

        if(this.data.c.P[pnum].t !== undefined){
            return(this.data.c.P[pnum].t);
        } else {
            return(null);
        }

    }

    translation(num){
        let pnum = this.projection(num);
        if(this.data.c.x.p && this.data.c.x.p[pnum].t){
            return(this.data.c.x.p[pnum].t);
        } else {
            return(null);
        }
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

    transformedCoords(num){
        let pnum           = this.projection(num);
        let coords         = this.data.c.P[pnum].l.slice();
        return(this.transformCoords(coords, pnum));
    }

    transformCoords(coords, num){
        let transformation = this.transformation(num);
        let translation    = this.translation(num)
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

    ptBaseCoords(i){
        if(this.data.c.P.length == 0) return(null);
        let pnum = this.projection();
        return(this.data.c.P[pnum].l[i].slice());
    }

    ptCoords(i){
        if(this.data.c.P.length == 0) return(null);
        return(
            Racmacs.utils.transformTranslateCoords(
                this.ptBaseCoords(i),
                this.transformation(),
                this.translation()
            )
        )
    }

    agBaseCoords(i){ return(this.ptBaseCoords(i)); }
    srBaseCoords(i){ return(this.ptBaseCoords(i + this.numAntigens())); }

    agCoords(i){ return(this.ptCoords(i)); }
    srCoords(i){ return(this.ptCoords(i + this.numAntigens())); }

    agSequences(i){
        if(this.data.c.x.a[0].q){
            if(i === undefined) return(this.data.c.x.a.map( p => p.q.split("") ));
            else                return(this.data.c.x.a[i].q.split(""));
        } else {
            return(null);
        }
    }

    srSequences(i){
        if(this.data.c.x.s[0].q){
            if(i === undefined) return(this.data.c.x.s.map( p => p.q.split("") ));
            else                return(this.data.c.x.s[i].q.split(""));
        } else {
            return(null);
        }
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

        // Apply minimum column basis
        if(this.data.c.P[pnum].m){
            mincolbasis = this.data.c.P[pnum].m;
        } else {
            mincolbasis = "none";
        }
        colbases = Racmacs.utils.calcColBases({
            titers: this.table(),
            mincolbasis: mincolbasis
        });

        // Apply fixed column bases
        if(this.data.c.P[pnum].C){
            // Forced column bases
            var fixed_colbases = this.data.c.P[pnum].C;
            for(var j=0; j<fixed_colbases.length; j++){
                if (fixed_colbases[j] !== null) {
                    colbases[j] = fixed_colbases[j];
                }
            }
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
    triangulationBlobs(num){
        let pnum = this.projection(num);
        if(!this.data.diagnostics
            || !this.data.diagnostics[pnum]
            || !this.data.diagnostics[pnum].stress_blobs){
            return(null)
        } else {
            return(this.data.diagnostics[pnum].stress_blobs)
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

