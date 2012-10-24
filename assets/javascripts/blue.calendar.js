jQuery.extend({
    keys: function(obj){
        var a = [];
        jQuery.each(obj, function(k){ a.push(k) });
        return a;
    }
});

//**************************************************************************************************
// ********************* CALENDAR VIEW ******* CALENDAR VIEW ******* CALENDAR VIEW ****************
//**************************************************************************************************
// ********************* CALENDAR VIEW ******* CALENDAR VIEW ******* CALENDAR VIEW ****************
//**************************************************************************************************
// ********************* CALENDAR VIEW ******* CALENDAR VIEW ******* CALENDAR VIEW ****************
//**************************************************************************************************


jQuery.fn.calendar = function(settings) {
	
	var MONTH_NAMES = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
	var current_month = new Date();
	var DAY_HEIGHT = 0;
	
	settings = jQuery.extend(
		{
			categories : jQuery("#categories"),
			previous_month: jQuery("#previous_month"),
			present_month: jQuery("#present_month"),
			next_month : jQuery("#next_month"),
			month_label : jQuery("#month span"),
			calendar_view : jQuery(".tools .calendar"),
			list_view : jQuery(".tools .list"),
			event_url : "/events/event.aspx"
		}, settings
	);
	
	var categories = settings.categories;
	var calendar = jQuery(this);
    
    calendar = jQuery(this).extend({
		
		 hide_calendar: function() {
		    calendar.hide();
		    settings.previous_month.hide();
		    settings.present_month.hide();
		    settings.next_month.hide();
		    settings.calendar_view.removeClass("selected");
		    return false;
		},
		
		show_calendar: function() {
		    calendar.show();
		    settings.previous_month.show();
		    settings.present_month.show();
		    settings.next_month.show();
		    settings.calendar_view.addClass("selected");
		    set_month_label_text();
		    return false;
		},
		
				
		draw_month: function(year, month) {
		    draw_calendar({month:month, year:year});
		    return false;
		}
		
		});
		
		
	
		// Displays the Events on the calendar corresponding to the checked categories
		var display_events = function(params) {
			params = jQuery.extend({all:false}, params);
			
			if (params.all) {
				calendar.find("a").show().css("visibility", "visible");
			} else {
				calendar.find("a").hide();
				categories.find(":checked").each(function() {
						calendar.find("a."+this.name).show().css("visibility", "visible");
				});
			}
			
			clear_popups();
			check_for_day_overflow();
		}
		
		// Draw the events of a single day
		var draw_events = function(cell, date) {
			if (events_start_date[date.getFullYear()] && 
					events_start_date[date.getFullYear()][date.getMonth()] &&
					events_start_date[date.getFullYear()][date.getMonth()][date.getDate()]) {

				day = events_start_date[date.getFullYear()][date.getMonth()][date.getDate()];

				for(var i = 0; i < day.length; i++) {
					draw_event(cell, day[i])
				}
			}
		}
		
		// Draw a single event
		var draw_event = function(cell, data) {
		    // Retrieve from data array
		    data = event_data[data.id];
		    
			// Display or Hide?
			(category_displayed(data.categories) == false) ? display = "style=\"display:none\"" : display = "";
			
			// Insert on start date
			cell.append("<a href=\""+document.location.pathname+"/"+data.slug+"\" class=\""+data.categories.join(" ")+"\" "+display+">"+data.title+"</a>");
		
		}

		// Should an event of this category be displayed?
		var category_displayed = function(event_categories) {
			if (categories.find(":checkbox[name='all']").attr("checked") || categories.find(":checkbox").length == 0)
			    return true;
			else {
			    var categories_found = 0;
			    jQuery(event_categories).each(function(i, category) {
			        if (categories.find(":checkbox[name='"+category+"']").attr("checked"))
			            categories_found++;
			    });
			
			    if (categories_found)
			        return true
			    else			 
			        return false;
			}
		}
		
		
		// Check all days to see if there is any event overflow
		var check_for_day_overflow = function () {
			calendar.find("tbody td div.day").each(function(){
				jQuery(this).find(".more").remove();

				var links = jQuery(this).find("a");
				var div_number = jQuery(this).find("div.number")
				// If there are any events in the day
				if (links.length > 0) {
					var current_day_height = jQuery(this).find("div.number").innerHeight();
					var hidden_count = 0;

					// Count each link, and check the total height so far
					links.each(function(i){
					    //div_number.append("_" + jQuery(this.innerHeight())
					    if (jQuery(this).hidden() == false) { // Only work with events not already hidden
						    if ((current_day_height + jQuery(this).innerHeight()) > DAY_HEIGHT) {
							    jQuery(this).hide();
							    hidden_count++;
						    }
						    else
							    current_day_height += jQuery(this).innerHeight();
						}
					});

					// If there are too many events, hide them
					if (hidden_count > 0) {
						
						// Make sure there is still room for the more link
						if (current_day_height + 12 > DAY_HEIGHT) {
							jQuery(this).find("a:visible:last").hide();
							hidden_count++;
						}
						
						// Append more link
						jQuery(this).append("<a href=\"#\" class=\"more\">"+hidden_count+" More events &raquo;</a>");
						jQuery(this).find("a.more").bind("click", show_more_events);
					}
				}
			});
		}
		
		
		// Callback to popup all events of the day
		var show_more_events = function () {
			var day = jQuery(this).parent("div.day");
			popup = day.clone();

			popup.find("a").each(function(){
				if (category_displayed(jQuery(this).attr("class"))) {
					jQuery(this).css("display", "block");
				}
			})
			popup.find(".more").remove();

            
			// popup.find("a").append(" &raquo;")
			

			day_index = calendar.find("tbody tr td").index(day.parent("td")[0]) % 7;
			day_name = calendar.find("thead td:eq("+day_index+")").text();
			popup.find("div.number").append(" ("+day_name+")")
			popup.find("div.number").prepend("<a href=\"#\" class=\"close\">x</a>")
			popup.addClass("popup");
			
			day.parent("td").append(popup);

			popup.find("a.close").bind("click", close_popup);
			return false;
		}
		
		var set_month_label_text = function() {
			settings.month_label.text(MONTH_NAMES[current_month.getMonth()] + " " + current_month.getFullYear())
		}
		
		var set_arrow_urls = function(options) {
		    var prevMonth = new Date();
		    var nextMonth = new Date();
            var presentMonth = new Date();
		    prevMonth.setFullYear(options.year, options.month - 1, 1);
		    nextMonth.setFullYear(options.year, options.month + 1, 1);
		    if (settings.previous_month) settings.previous_month.attr("href", "#"+prevMonth.getFullYear()+"-"+(prevMonth.getMonth()+1));
		    if (settings.next_month) settings.next_month.attr("href", "#"+nextMonth.getFullYear()+"-"+(nextMonth.getMonth()+1));
            if (settings.present_month) settings.present_month.attr("href", "#"+presentMonth.getFullYear()+"-"+(presentMonth.getMonth()+1));
		}
		
		// Draw the entire calendar for the given :month and :year
		var draw_calendar = function (options) {

			clear_popups();
			clear_events();

			var calendar_date = new Date();
			options = jQuery.extend({month:calendar_date.getMonth(), year:calendar_date.getFullYear()}, options);
			calendar_date.setFullYear(options.year, options.month, 1);
			current_month.setFullYear(options.year, options.month, 1);

            set_month_label_text();
            set_arrow_urls(options);

			// Set month's days
			var cells = calendar.find("tbody td");
			var col = calendar_date.getDay();
			var first_cell = col;

			var this_month = calendar_date.getMonth();
			while (calendar_date.getMonth() == this_month) {
				number = jQuery(cells[col]).find("div.number")
				number.text(calendar_date.getDate());
				number.removeClass("other");

				draw_events(jQuery(cells[col]).find("div.day"), calendar_date);

				// Increment
				col++;
				calendar_date.setDate(calendar_date.getDate()+1);
			}

			var last_cell = col-1;

			// Display 5 or 6 rows
			if (jQuery(cells[last_cell]).parent("tr").is(":last-child"))
				show_six_rows();
			else
				show_five_rows();

			// Pad first row
			var previous_month = new Date();
			previous_month.setFullYear(options.year, options.month, 1);
			previous_month.setDate(previous_month.getDate()-1);

			for (var i = first_cell - 1; i >= 0; i--) {
				number = jQuery(cells[i]).find("div.number")
				number.text(previous_month.getDate());
				number.addClass("other")

				draw_events(jQuery(cells[i]).find("div.day"), previous_month);
				previous_month.setDate(previous_month.getDate()-1);
			}

			// Pad last row
			var next_month = new Date();
			next_month.setFullYear(options.year, options.month, 1);
			next_month.setMonth(next_month.getMonth()+1);

			for (var i = last_cell + 1; i < cells.length; i++) {
				number = jQuery(cells[i]).find("div.number")
				number.text(next_month.getDate());
				number.addClass("other");

				draw_events(jQuery(cells[i]).find("div.day"), next_month);
				next_month.setDate(next_month.getDate()+1);
			}

			check_for_day_overflow();
		}
		
		
		// Toggle between five or six rows in the calendar
		var show_five_rows = function () {
			calendar.find("tbody tr:last").hide();
			calendar.addClass("five_rows");
			DAY_HEIGHT = calendar.find("tbody td:first-child div.day").innerHeight();
		}

		var show_six_rows = function() {
			calendar.find("tbody tr:last").show().css("visibility", "visible");
			calendar.removeClass("five_rows");
			DAY_HEIGHT = calendar.find("tbody td:first-child div.day").innerHeight();
			
			if (jQuery.browser.msie && jQuery.browser.version < 7) {
		        calendar.find("thead").css("height","10px");
		        calendar.find("thead tr").css("height","10px");
		        calendar.find("thead tr td").css("height","10px");
		    }
		}
		
		
		// Functions to switch months
		var draw_next_month = function() {
			var next_month = new Date();
			return calendar.draw_month(current_month.getFullYear(), current_month.getMonth()+1);
		}

		var draw_previous_month = function() {
			var previous_month = new Date();
			return calendar.draw_month(current_month.getFullYear(), current_month.getMonth()-1);

}

var draw_present_month = function () {
    var present_month = new Date();
    return calendar.draw_month(present_month.getFullYear(), present_month.getMonth());

}


		
		
		/* Utilities for clearing and closing */
		var close_popup = function() {
			jQuery(this).parent().parent().remove();
			return false;
		}

		var clear_popups = function () {
			calendar.find("div.popup").remove();
		}
		
		var clear_events = function () {
			calendar.find("a").remove();
		}
		
	
		
		// Set up the category checkboxes
		categories.find(":checkbox").click(function(){
			if (this.name == "all") {
				if (categories.find(":checkbox[name='all']").attr("checked") == false) {
					// Force 'all' to be checked
					categories.find(":checkbox[name='all']").attr("checked", true)
				}
				// Uncheck all categories but 'all'
				categories.find(":checkbox[name!='all']").attr("checked", false);
				display_events({all:true});
			} else {
				categories.find(":checkbox[name='all']").attr("checked", false);
				display_events();
			}
		});

		// Set the default checkbox states
		categories.find(":checkbox").attr("checked", false);
		categories.find(":checkbox[name='all']").attr("checked", true)

		// Set up the month controls
		if (settings.previous_month) settings.previous_month.bind("click", draw_previous_month);
		if (settings.next_month) settings.next_month.bind("click", draw_next_month);
		if (settings.present_month) settings.present_month.bind("click", draw_present_month);
		
		// Set up actions for the views
		settings.calendar_view.bind("click", calendar.show_calendar);
		settings.list_view.bind("click", calendar.hide_calendar);
		
		// Draw the calendar
		draw_calendar();
 
    return calendar;
  

};


jQuery.fn.calendarElementHeight = function() {
	if (jQuery.browser.msie)
		return jQuery(this).innerHeight();
	else
		return jQuery(this).innerHeight();
};

jQuery.fn.hidden = function() {
	if (jQuery(this).css("display") == "none")
		return true;
	else
		return false;
};




//**************************************************************************************************
// *********************** LIST VIEW *********** LIST VIEW *********** LIST VIEW ******************
//**************************************************************************************************
// *********************** LIST VIEW *********** LIST VIEW *********** LIST VIEW ******************
//**************************************************************************************************
// *********************** LIST VIEW *********** LIST VIEW *********** LIST VIEW ******************
//**************************************************************************************************

jQuery.fn.event_list = function (settings) {
    var MONTH_NAMES = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    var current_month = new Date();
    var cal_list_scrollbar;


    settings = jQuery.extend(
		{
		    categories: jQuery("#categories"),
		    event_list: jQuery("#list_events tbody"),
		    calendar_view: jQuery(".tools .calendar"),
		    list_view: jQuery(".tools .list"),
		    previous_year: jQuery("#previous_year"),
		    present_year: jQuery("#present_year"),
		    next_year: jQuery("#next_year"),
		    year_label: jQuery("#month span"),
		    event_url: "/events/event.aspx"
		}, settings
	);

    var categories = settings.categories;
    var event_list = settings.event_list;
    var list = jQuery(this);
    var current_year = new Date();

    list = jQuery(this).extend({

        hide_list: function () {
            list.hide();
            settings.previous_year.hide();
            settings.present_year.hide();
            settings.next_year.hide();
            settings.list_view.removeClass("selected");
            return false;
        },

        show_list: function () {
            list.show();
            list.find("div").show();
            settings.previous_year.show();
            settings.present_year.show();
            settings.next_year.show();
            settings.list_view.addClass("selected");
            set_year_label_text();
            draw_scrollbar();
            scroll_to_month(current_month.getMonth());
            return false;
        },

        draw_year: function (year) {
		            draw_calendar({year: year });
		            return false;
		}

    });

    // Displays the Events on the calendar corresponding to the checked categories
    var display_events = function (params) {
        params = jQuery.extend({ all: false }, params);

        if (params.all) {
            event_list.find("tr:not(.month)").show();
        } else {
            event_list.find("tr:not(.month)").hide();
            categories.find(":checked").each(function () {
                event_list.find("tr." + this.name).show();
            });
        }

        display_month_labels();

        draw_scrollbar();
    }

    var display_month_labels = function () {
        for (var i = 1; i < 13; i++) {
            if (jQuery("tr.month_" + i + ":visible").length > 0)
                jQuery("tr.month_label_" + i).show();
            else
                jQuery("tr.month_label_" + i).hide();
        }
    };

    var set_year_label_text = function () {
        settings.year_label.text(current_year.getFullYear() + " Events List");
    }

    var set_arrow_urls_year = function (options) 
{
    var prevYear = new Date();
    var nextYear = new Date();
    var presentYear = new Date();
    prevYear.setFullYear(options.year - 1);
    nextYear.setFullYear(options.year + 1);
    if (settings.previous_year) settings.previous_year.attr("href", "#list-" + prevYear.getFullYear());
    if (settings.next_year) settings.next_year.attr("href", "#list-" + nextYear.getFullYear());
    if (settings.present_year) settings.present_year.attr("href", "#list-" + nextYear.getFullYear());
}

    var draw_calendar = function (options) {
        options = jQuery.extend({ year: current_year.getFullYear() }, options);

        current_year.setFullYear(options.year);

        // Clear event list
        event_list.find("tr").remove();
        set_year_label_text();
        set_arrow_urls_year(options);
        for (var month = 0; month < 12; month++) {
            options.month = month;
            draw_events(options);
        }



    };

    var scroll_to_month = function (month) {
        if (cal_list_scrollbar && cal_list_scrollbar[0] && cal_list_scrollbar[0].scrollTo)
            cal_list_scrollbar[0].scrollTo("a[name='month_anchor_" + (month + 1) + "']");
    }

    var draw_month = function (month) {
        event_list.append('<tr class="month_anchor"><td colspan="4"><a name="month_anchor_' + (month + 1) + '"></a></td></tr><tr class="month month_label_' + (month + 1) + '">' +
		                      '<td class="category"></td>' +
		                      '<td colspan="3">' + MONTH_NAMES[month] + '</td>' +
		                   '</tr>');
    }

    // Draw the events of a single day
    var draw_events = function (options) {
        if (events_start_date[options.year] &&
				events_start_date[options.year][options.month]) {

            draw_month(options.month);
            days = events_start_date[options.year][options.month]

            days_keys = jQuery.keys(days).sort(function (a, b) {
                return parseInt(a) - parseInt(b)
            });

            jQuery.each(days_keys, function () {
                day_number = this
                jQuery.each(days[this], function () {
                    options.day = day_number;
                    draw_event(options, this);
                });
            });
        }
    }

    // Draw a single event
    var draw_event = function (options, data) {

        // Retrieve from data array
        data = event_data[data.id];

        // Display or Hide?
        (category_displayed(data.category) == false) ? display = "style=\"display:none\"" : display = "";

        event_list.append('<tr class="' + data.categories.join(" ") + ' month_' + (options.month + 1) + '" ' + display + '>' +
		                      '<td class="category"></td>' +
		                      '<td style="width:100px;">' + (options.month + 1) + '/' + options.day + '/' + options.year + '</td>' +
		                      '<td style="width:100px;">' + (data.time) + '</td>' +
		                      '<td><a href="' +document.location.pathname+"/"+data.slug+ '">' + data.title + '</a></td>' +
		                   '</tr>');
    }

    // Should an event of this category be displayed?
    var category_displayed = function (category) {
        if (categories.find(":checkbox[name='all']").attr("checked") || categories.find(":checkbox[name='" + category + "']").attr("checked") || categories.find(":checkbox").length == 0)
            return true;
        else
            return false;
    }



    var draw_scrollbar = function () {
        if (jQuery.jScrollPane && list.css("display") == "block")
            cal_list_scrollbar = list.find("#list_events").jScrollPane({ dragMaxHeight: 73, dragMinHeight: 73, scrollbarWidth: 9, scrollbarDragWidth: 9, scrollbarMargin: 0 });
    }

    categories.find(":checkbox").click(function () {
	    	if (this.name == "all") {
					if (categories.find(":checkbox[name='all']").attr("checked") == false) {
						// Force 'all' to be checked
						categories.find(":checkbox[name='all']").attr("checked", true)
					}
					// Uncheck all categories but 'all'
					categories.find(":checkbox[name!='all']").attr("checked", false);
					display_events({all:true});
				} else {
					categories.find(":checkbox[name='all']").attr("checked", false);
					display_events();
				}



        // if (this.name == "all") {
        //     if (categories.find(":checkbox[name='all']").attr("checked") == true) {
        //         // Uncheck all categories but 'all'
        //         categories.find(":checkbox[name!='all']").attr("checked", false);
        //         display_events({ all: true });
        //     } else {
        //         // Force 'all' to be checked
        //         categories.find(":checkbox[name='all']").attr("checked", true)
        //     }
        // } else {
        //     categories.find(":checkbox[name='all']").attr("checked", false);
        //     display_events();
        // }
    });


    // Functions to switch years
    // switch to next year
    var draw_next_year = function () {
        var next_year = new Date();
        return list.draw_year(current_year.getFullYear() + 1);
    }

    // switch to previous year
    var draw_previous_year = function () {
        var previous_year = new Date();
        return list.draw_year(current_year.getFullYear() - 1);
    }

    // switch to present year
    var draw_present_year = function () {
        var present_year = new Date();
        return list.draw_year(present_year.getFullYear());
    }


    // Set up the year controls
    if (settings.previous_year) settings.previous_year.bind("click", draw_previous_year);
    if (settings.next_year) settings.next_year.bind("click", draw_next_year);
    if (settings.present_year) settings.present_year.bind("click", draw_present_year);

    // Set up actions for the views
    settings.calendar_view.bind("click", list.hide_list);
    settings.list_view.bind("click", list.show_list);

    draw_calendar();

    return list;
}



jQuery(document).ready(function(){
	
	var history_callback_locked = false;
	// set onlick event for buttons
	jQuery("a[rel='history']").click(function(){
		// 
		var hash = this.href;
		hash = hash.replace(/^.*#/, '');

		jQuery.history.load(hash+hashCategories(), false);
	
		return false;
	});
			
    function hashCategories() {
        var hash = location.hash
		hash = hash.replace(/^.*#/, '');
		new_hash = ""
		
		jQuery("#categories").find(":checkbox[name!='all']").each(function(i, checkbox) {
            if (hash.indexOf(this.name) >= 0)
                new_hash += "-"+this.name;
        });
        
        return new_hash;
    }			
			
    jQuery("#categories").find(":checkbox[name!='all']").click(function(){
        var hash = location.hash
		hash = hash.replace(/^.*#/, '');
        if (hash == "") hash = "calendar";

        if (this.checked) {
            if (hash.indexOf(this.name) < 0)
                hash = hash + "-" + this.name;
        } else {
            if (hash.indexOf(this.name) >= 0)
                hash = hash.replace("-"+this.name, "");
        }
        jQuery.history.load(hash, false);
    });
    
    jQuery("#categories").find(":checkbox[name='all']").click(function(){
        var hash = location.hash
		hash = hash.replace(/^.*#/, '');
		if (hash == "") hash = "calendar";
		
        jQuery("#categories").find(":checkbox").each(function(i, checkbox) {
            hash = hash.replace("-"+checkbox.name, "");
        });
        
       
        jQuery.history.load(hash, false);
       
    });
	
	// Span multiple-day events over multiple days
	jQuery.each(event_data, function(i, data) {
      if (data.start != data.end) {
        start = new Date(data.start)
        end = new Date(data.end)
        
        while (start < end) {
            start.setDate(start.getDate() + 1);
        
            if (!events_start_date[start.getFullYear()] || !events_start_date[start.getFullYear()][start.getMonth()] || !events_start_date[start.getFullYear()][start.getMonth()][start.getDate()]) {
                events_start_date[start.getFullYear()][start.getMonth()][start.getDate()] = new Array();
            }
            events_start_date[start.getFullYear()][start.getMonth()][start.getDate()].push({id:i});
        }
      }
    });

	
	

});

function initCalendar(settings) {
    var calendar = jQuery("#calendar").calendar(settings);
	var event_list = jQuery("#list").event_list(settings);

	// Initialize history plugin.
	// The callback is called at once by present location.hash. 
	jQuery.history.init(function(hash) {
		// hash doesn't contain the first # character.
		if (hash.length > 0) {
		   
		    var categories = hash.split("-");
		    jQuery(categories).each(function(i, category){
		    	//if (jQuery("#categories input:checkbox[name='"+ category +"']").is(":checked") == false) {
		        jQuery("#categories input:checkbox[name='"+ category +"']").attr("checked", "checked").trigger("click").attr("checked", "checked");
		   			
		   		//}
		    });
		
		    if (hash.indexOf("list") >= 0) {
		        // var year = parseInt(hash.replace("list", "").replace("-", ""))
		        // console.log(year)
		        // if (year && year != "") event_list.draw_year(year);
		        event_list.show_list();
		        calendar.hide_calendar();
		    }
		    else if (hash.indexOf("calendar") >= 0) {
		        calendar.show_calendar();
		        event_list.hide_list();
		    }
		    else {
		        // Parse month
		        var date = hash.split("-");
		        
		        calendar.show_calendar();
		        event_list.hide_list();
		        calendar.draw_month(parseInt(date[0]), parseInt(date[1]) - 1);
		    }
		    
		   
		}
		else{
		    calendar.show_calendar();
		    event_list.hide_list();
		}
		
 
	});

}

