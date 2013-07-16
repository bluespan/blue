//Extend WYMeditor
WYMeditor.editor.prototype.blue_insert_paragraph = function(options) {
  var html = "<li class='wym_tools_newbutton'>"
           + "<a name='NewButton' href='#'"
           + " style='background-image:"
           + " url(/javascripts/blue/wymeditor/skins/default/icons.png);"
           + " background-position: 0 -264px;'>"
           + "Insert paragraph after"
           + "</a></li>";
  wym = this;
  //add the button to the tools box
  jQuery(wym._box)
  .find(wym._options.toolsSelector + wym._options.toolsListSelector)
  .append(html);

  //handle click event
  jQuery(wym._box)
  .find('li.wym_tools_newbutton a').click(function() {
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
        jQuery(container).after("<p>" + "</p>");
        wym.setFocusToNode(jQuery(container).next().get(0))

        jQuery(wym._doc.body).scrollTop(jQuery(container).next().offset().top - 50)
      } else {      
        jQuery(wym._doc.body).append("<p>" + "</p>");
        jQuery(wym._doc.body).scrollTop(jQuery(wym._doc).height())
        wym.setFocusToNode(jQuery("body p:last-child").get(0))
        jQuery(wym._doc.body).scrollTop(jQuery(wym._doc).height())
      }
      return(false);
  });

  return this;
};
