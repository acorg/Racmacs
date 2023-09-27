

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
        this.origtitertable = this.getTable();
        this.origlogtitertable = Racmacs.utils.logTiters(this.titertable);
        this.pnum = 0;
        this.dilutionstepsize_cache = this.dilutionStepsize();
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
        if (this.numProjections() > 0) {
            this.data.c.P[this.pnum].s = stress;
        }
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
                return(Array(ndims).fill(null));
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

    setTiter(ag, sr, value, update_cbases = true){

        // Set titer table record
        if (this.titertable) this.titertable[ag][sr] = value;

        // If table data provided as a list of objects
        if(this.data.c.t.d) {
            this.data.c.t.d[ag][sr.toString()] = value;
        } else {
            this.data.c.t.l[ag][sr] = value;
        }

        // Update the column bases cache
        if (update_cbases) this.update_colbases();

        // Update the logtiter cache
        this.logtitertable = Racmacs.utils.logTiters(this.titertable);

        // Log the change in the console
        console.log("Titer data updated");


    }

    restoreTiter(ag, sr, update_cbases = true){

        var value = this.origtitertable[ag][sr];

        // Set titer table record
        if (this.titertable) this.titertable[ag][sr] = value;

        // If table data provided as a list of objects
        if(this.data.c.t.d) {
            this.data.c.t.d[ag][sr.toString()] = value;
        } else {
            this.data.c.t.l[ag][sr] = value;
        }

        // Update the column bases cache
        if (update_cbases) this.update_colbases();

        // Update the logtiter cache
        this.logtitertable = Racmacs.utils.logTiters(this.titertable);

        // Log the change in the console
        console.log("Titer data updated");


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
    stress(i){
        if (i === undefined) i = this.pnum;
        if(this.numProjections() > 0 && this.data.c.P[i] && this.data.c.P[i].s){
            return(this.data.c.P[i].s);
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

    agGroupValues(i){
        if (i === undefined) {
            if (this.data.c.x && this.data.c.x.a) {
                return(this.data.c.x.a.map( a => a.g ));
            } else {
                return(this.data.c.a.map( a => undefined ));
            }
        } else {
            if (this.data.c.x && this.data.c.x.a) {
                return(this.data.c.x.a[i].g);
            } else {
                return(undefined);
            }
        }
    }

    srGroupValues(i){
        if (i === undefined) {
            if (this.data.c.x && this.data.c.x.s) {
                return(this.data.c.x.s.map( s => s.g ));
            } else {
                return(this.data.c.s.map( a => undefined ));
            }
        } else {
            if (this.data.c.x && this.data.c.x.s) {
                return(this.data.c.x.s[i].g);
            } else {
                return(undefined);
            }
        }
    }

    agGroupLevelFill(){
        var ag_group_levels = this.agGroupLevels();
        var ag_group_values = this.agGroupValues();
        var vals = ag_group_levels.map((level, i) => {
            if (ag_group_values.indexOf(i) == -1) return("black");
            else return(this.agFill(ag_group_values.indexOf(i)));
        });
        return(vals);
    }

    agGroupLevelOutline(){
        var ag_group_levels = this.agGroupLevels();
        var ag_group_values = this.agGroupValues();
        var vals = ag_group_levels.map((level, i) => {
            if (ag_group_values.indexOf(i) == -1) return("black");
            else return(this.agOutline(ag_group_values.indexOf(i)));
        });
        return(vals);
    }

    srGroupLevelFill(){
        var sr_group_levels = this.srGroupLevels();
        var sr_group_values = this.srGroupValues();
        var vals = sr_group_levels.map((level, i) => {
            if (sr_group_values.indexOf(i) == -1) return("black");
            else return(this.srFill(sr_group_values.indexOf(i)));
        });
        return(vals);
    }

    srGroupLevelOutline(){
        var sr_group_levels = this.srGroupLevels();
        var sr_group_values = this.srGroupValues();
        var vals = sr_group_levels.map((level, i) => {
            if (sr_group_values.indexOf(i) == -1) return("black");
            else return(this.srOutline(sr_group_values.indexOf(i)));
        });
        return(vals);
    }

    agGroupLevels(){
        if (this.data.c.x) {
            return(this.data.c.x.agv);
        } else {
            return(undefined);
        }
    }

    srGroupLevels(){
        if (this.data.c.x) {
            return(this.data.c.x.srv);
        } else {
            return(undefined);
        }
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

    setAgReactivityAdjustment(i, value){
        let pnum = this.projection();
        if (!this.data.c.x) this.data.c.x = {};
        if (!this.data.c.x.p) this.data.c.x.p = Array(this.numProjections()).fill({});
        if (!this.data.c.x.p[pnum].r) this.data.c.x.p[pnum].r = Array(this.numAntigens()).fill(0);
        this.data.c.x.p[pnum].r[i] = value;
        this.update_colbases();
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

    agSequences(){

        let seqs = this.data.c.a.map((p, i) => {
            if (p.A) {
                return(p.A.split(""));
            } else if (this.data.c.x && this.data.c.x.a && this.data.c.x.a[i].q) {
                return(this.data.c.x.a[i].q.split(""));
            } else {
                return([]);
            }
        });
        let maxlen = Math.max(...seqs.map(s => s.length));
        seqs = seqs.map(s => {
            while(s.length < maxlen) {
                s.push(".");
            }
            return(s);
        });
        return(seqs);

    }

    srSequences(){
        
        let seqs = this.data.c.s.map((p, i) => {
            if (p.A) {
                return(p.A.split(""));
            } else if (this.data.c.x && this.data.c.x.s && this.data.c.x.s[i].q) {
                return(this.data.c.x.s[i].q.split(""));
            } else {
                return([]);
            }
        });
        let maxlen = Math.max(...seqs.map(s => s.length));
        seqs = seqs.map(s => {
            while(s.length < maxlen) {
                s.push(".");
            }
            return(s);
        });
        return(seqs);

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
        return(
            Racmacs.utils.RemoveColorOpacity(
                this.agPlotspec(i, "F", "green")
            )
        );
    }
    srFill(i){
        return(
            Racmacs.utils.RemoveColorOpacity(
                this.srPlotspec(i, "F", "transparent")
            )
        );
    }

    agOutline(i){
        return(
            Racmacs.utils.RemoveColorOpacity(
                this.agPlotspec(i, "O", "black")
            )
        );
    }
    srOutline(i){
        return(
            Racmacs.utils.RemoveColorOpacity(
                this.srPlotspec(i, "O", "black")
            )
        );
    }

    agFillOpacity(i){
        return(
            Racmacs.utils.ExtractColorOpacity(
                this.agPlotspec(i, "F", "green")
            )
        );
    }
    srFillOpacity(i){
        return(
            Racmacs.utils.ExtractColorOpacity(
                this.srPlotspec(i, "F", "transparent")
            )
        );
    }

    agOutlineOpacity(i){
        return(
            Racmacs.utils.ExtractColorOpacity(
                this.agPlotspec(i, "O", "black")
            )
        );
    }
    srOutlineOpacity(i){
        return(
            Racmacs.utils.ExtractColorOpacity(
                this.srPlotspec(i, "O", "black")
            )
        );
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

    // Extras
    dilutionStepsize(){
        if (this.data.c.x && this.data.c.x.ds !== undefined) {
            return(this.data.c.x.ds);
        } else {
            return(1);
        }
    }

    // Excluding and including points
    includePoint(type, i) {
        if (type == "ag") {
            for (var j=0; j<this.numSera(); j++) {
                this.restoreTiter(i, j, false);
            }
        } else {
            for (var j=0; j<this.numAntigens(); j++) {
                this.restoreTiter(j, i, false);
            }
        }
        this.update_colbases();
    }

    excludePoint(type, i) {
        if (type == "ag") {
            for (var j=0; j<this.numSera(); j++) {
                this.setTiter(i, j, "*", false);
            }
        } else {
            for (var j=0; j<this.numAntigens(); j++) {
                this.setTiter(j, i, "*", false);
            }
        }
        this.update_colbases();
    }

}

