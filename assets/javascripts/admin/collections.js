$(document).ready(function(){
  $("table a.delete").click(function(){
    var title = $(this).parents("tr").find("td.name, td:first-child").last().text()
    return confirm("Are you sure you want to delete: "+title+ "?")
  })
})