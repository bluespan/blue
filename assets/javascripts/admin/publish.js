$(document).ready(function(){
	bind_pages("#pending_publish .list li");
	
	// Bind Publish All
	$('#pending_publish .publish_all').click(function() {
		params = {"_method":"put", "authenticity_token":form_authenticity_token}
		$.post($(this).attr("href") + ".js", params, null, "script");
		return false
	})
	
});

function bind_pages(page) {
	
	// Bind Publish
	$(page).find('.publish').click(function() {
		params = {"_method":"put", "authenticity_token":form_authenticity_token}
		$.post($(this).attr("href") + ".js", params, null, "script");
		return false
	})
	
	// Bind Revert
	$(page).find('.revert').click(function() {
		if (confirm("Are you sure you want to revert page: '"+$(this).parents("li").find(".title").text()+"' and lose all changes?"))
		{
			params = {"_method":"delete", "authenticity_token":form_authenticity_token}
			$.post($(this).attr("href") + ".js", params, null, "script");
		}
		return false
	})
}
