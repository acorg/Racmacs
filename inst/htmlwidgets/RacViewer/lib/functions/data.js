

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
        this.titertable = this.getTable();
        this.logtitertable = Racmacs.utils.logTiters(this.titertable);
        this.pnum = 0;
    }

    // Set the projection
    setProjection(num){
        this.pnum = num;
        this.update_colbases();
    }

    // For calculating the number of titers
    numTiters(){
        var ntiters = 0;
        this.titertable.map(
            row => row.map(
                titer => {
                    if (Racmacs.utils.titerType(titer) != 0) {
                        ntiters++;
                    }
                }
            )
        )
        return(ntiters);
    }

    numDetectableTiters(){
        var ntiters = 0;
        this.titertable.map(
            row => row.map(
                titer => {
                    if (Racmacs.utils.titerType(titer) == 1) {
                        ntiters++;
                    }
                }
            )
        )
        return(ntiters);
    }

    // For updating stress
    updateStress(stress) {
        this.data.c.P[this.pnum].s = stress;
    }

    // For resetting tranformation and translation information
    resetTransformation() {
        delete this.data.c.P[this.pnum].t;
    }
    resetTranslation() {
        if(this.data.c.x && this.data.c.x.p && this.data.c.x.p[this.pnum].t) {
            delete this.data.c.x.p[this.pnum].t;
        }
    }

    // For updating base coordinates
    updateBaseCoords(coords) {
        this.data.c.P[this.pnum].l = coords;
    }

    // For updating coordinates after points have been moved 
    // in the viewer
    updateCoords() {
        
        // Get variables
        let ndims = this.dimensions();
        let coords = this.viewer.points.map( p => {
            if (p.coords_na) {
                return([]);
            } else {
                return(p.getPosition().slice(0, ndims));
            }
        });

        // Reset any transformations
        this.resetTransformation();
        this.resetTranslation();

        // Apply the coordinate change
        this.updateBaseCoords(coords);

        // Log the change in the console
        console.log("Coords data updated");
        

    }

    // Return selected projection
    projection() {
        return(this.pnum);
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

    numAntigens(){
        if(!this.data){ return(0) }
        return(this.data.c.a.length);
    }

    numSera(){
        if(!this.data){ return(0) }
        return(this.data.c.s.length);
    }

    numPoints(){
        return(this.numAntigens() + this.numSera());
    }

    getTable(){

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
        return(this.logtitertable);
    }

    logtiter(ag, sr){
        return(this.logtitertable[ag][sr]);
    }

    adjustedlogtiter(ag, sr) {
        return(this.logtiter(ag, sr) + this.agReactivityAdjustment(ag));
    }

    tableDist(ag, sr) {
        return(this.colbases(sr) - this.adjustedlogtiter(ag, sr));
    }

    titerType(ag, sr) {
        return(
            Racmacs.utils.titerType(
                this.titertable[ag][sr]
            )
        );
    }

    // Projection attributes
    stress(){
        if(this.data.c.P[this.pnum] && this.data.c.P[this.pnum].s){
            return(this.data.c.P[this.pnum].s);
        } else {
            return(0);
        }
    }

    transformation(){
        if(this.data.c.P.length == 0) return(null)
        if(this.data.c.P[this.pnum].t !== undefined){
            return(this.data.c.P[this.pnum].t);
        } else {
            return(null);
        }

    }

    translation(){
        if(this.data.c.x && this.data.c.x.p && this.data.c.x.p[this.pnum].t){
            return(this.data.c.x.p[this.pnum].t);
        } else {
            return(null);
        }
    }

    dimensions(){
        if(this.data.c.P.length == 0) return(null)
        return(
            Math.max(...this.data.c.P[this.pnum].l.map( p => p.length ))
        );
    }

    transformedCoords(num){
        let pnum           = this.projection(num);
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

    agReactivityAdjustment(i){
        let pnum = this.projection();
        if (this.data.c.x && this.data.c.x.p && this.data.c.x.p[pnum].r) {
            if (i === undefined) {
                return(this.data.c.x.p[pnum].r)
            } else {
                return(this.data.c.x.p[pnum].r[i]);
            }
        } else {
            if (i === undefined) {
                return(Array(this.numAntigens()).fill(0));
            } else {
                return(0);
            }
        }
    }

    ptBaseCoords(i){
        if(this.data.c.P.length == 0) return(null);
        if(i === undefined) return(this.data.c.P[this.pnum].l.slice());
        return(this.data.c.P[this.pnum].l[i].slice());
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

    agBaseCoords(i){ 
        if (i === undefined) return(this.ptBaseCoords().slice(0, this.numAntigens()));
        else                 return(this.ptBaseCoords(i)); 
    }
    srBaseCoords(i){ 
        if (i === undefined) return(this.ptBaseCoords().slice(this.numAntigens(), this.numPoints()));
        else                 return(this.ptBaseCoords(i + this.numAntigens())); 
    }

    agCoords(i){ return(this.ptCoords(i)); }
    srCoords(i){ return(this.ptCoords(i + this.numAntigens())); }

    agSequences(i){
        if(this.data.c.x && this.data.c.x.a && this.data.c.x.a[0].q){
            if(i === undefined) return(this.data.c.x.a.map( p => p.q.split("") ));
            else                return(this.data.c.x.a[i].q.split(""));
        } else {
            return(null);
        }
    }

    srSequences(i){
        if(this.data.c.x && this.data.c.x.s && this.data.c.x.s[0].q){
            if(i === undefined) return(this.data.c.x.s.map( p => p.q.split("") ));
            else                return(this.data.c.x.s[i].q.split(""));
        } else {
            return(null);
        }
    }

    colbases(i=null){
        if(i === null){
            return(this.colbase_cache);
        } else {
            return(this.colbase_cache[i]);
        }
    }

    minColBasis(){
        if(this.data.c.P[this.pnum] && this.data.c.P[this.pnum].m){
            return(this.data.c.P[this.pnum].m);
        } else {
            return("none");
        }
    }

    update_colbases(){

        let colbases;

        // Apply minimum column basis
        var mincolbasis = this.minColBasis();
        colbases = Racmacs.utils.calcColBases({
            titers: this.titertable,
            mincolbasis: mincolbasis,
            ag_reactivity_adjustment: this.agReactivityAdjustment()
        });

        // Apply fixed column bases
        if(this.data.c.P[this.pnum] && this.data.c.P[this.pnum].C){
            // Forced column bases
            var fixed_colbases = this.data.c.P[this.pnum].C;
            for(var j=0; j<fixed_colbases.length; j++){
                if (fixed_colbases[j] !== null) {
                    colbases[j] = fixed_colbases[j];
                }
            }
        }

        // Update the cache
        this.colbase_cache = colbases;

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
    triangulationBlobs(){
        if(!this.data.diagnostics
            || !this.data.diagnostics[this.pnum]
            || !this.data.diagnostics[this.pnum].triangulation_blobs){
            return(null)
        } else {
            return(this.data.diagnostics[this.pnum].triangulation_blobs)
        }
    }

    // Bootstrap data
    bootstrap(){
        return(this.data.c.x.bootstrap);
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

