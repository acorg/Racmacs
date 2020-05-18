
Racmacs.Table = class RacTable extends Racmacs.App {

	constructor(container, settings = {}){

		if(settings.autosize === undefined){
			settings.autosize = true;
		}

		super(container, settings);
		this.container = container;
		this.selected_pts = [];

		if(settings.autosize){
			this.container.style.height = null;
			this.container.style.width = null;
		}

		new Racmacs.Data(this);

	}

	load(mapdata, args){

		this.container.innerHTML = "";
		this.data.load(mapdata);

		// Add antigen and sera
    	this.addAntigensAndSera(mapdata, false);

    	// View the table
		this.table = new Racmacs.HItable(
			this, 
			this.container,
			{
				fixHeaders : false
			}
		);

	}

	resize(){

	}

}
