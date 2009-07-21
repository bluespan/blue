$(document).ready(function(){
	bind_pages("#pending_publish .list li");
	
	// Bind Publish All
	$('#pending_publish .publish_all').click(function() {
		$.post($(this).attr("href") + ".js", "_method=put&authenticity_token="+form_authenticity_token, null, "script");
		return false
	})
	
});

function bind_pages(page) {
	
	// Bind Publish
	$(page).find('.publish').click(function() {
		$.post($(this).attr("href") + ".js", "_method=put&authenticity_token="+form_authenticity_token, null, "script");
		return false
	})
}
