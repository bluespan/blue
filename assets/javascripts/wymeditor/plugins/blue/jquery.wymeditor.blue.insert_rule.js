//Extend WYMeditor
WYMeditor.editor.prototype.blue_insert_rule = function(options) {
  var html = "<li class='wym_tools_hrbutton'>"
           + "<a name='HrButton' href='#'"
           + " style='background-image:"
           + " url(/javascripts/blue/wymeditor/skins/default/icons.png);"
           + " background-position: 0 -477px;'>"
           + "Insert paragraph after"
           + "</a></li>";
  wym = this;
  //add the button to the tools box
  jQuery(wym._box)
  .find(wym._options.toolsSelector + wym._options.toolsListSelector).find(".wym_tools_paste")
  .after(html);

  //handle click event
  jQuery(wym._box)
  .find('li.wym_tools_hrbutton a').click(function() {
      //do something
      container = wym.selected();
      if (container && container.tagName.toLowerCase() != WYMeditor.BODY)
      {
        while (jQuery(container).is(":not(h1,h2,h3,h4,h5,h6,p,blockquote,body,ul,ol,table)")) {
          container = jQuery(container).parent()
        }
        if (jQuery(container).parent().is('blockquote') && jQuery(container).is(":last-child")) {
          container = jQuery(container).parent()

        }
        jQuery(container).after("<hr>");
        wym.setFocusToNode(jQuery(container).next().get(0))

        jQuery(wym._doc.body).scrollTop(jQuery(container).next().offset().top - 50)
      } else {      
        jQuery(wym._doc.body).append("<hr>");
        jQuery(wym._doc.body).scrollTop(jQuery(wym._doc).height())
        wym.setFocusToNode(jQuery("body p:last-child").get(0))
        jQuery(wym._doc.body).scrollTop(jQuery(wym._doc).height())
      }
      return(false);
  });

  return this;
};
