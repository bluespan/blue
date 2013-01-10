# modified by blue
# Page.types = [PageTypes::SubPage, PageTypes::HomePage, PageTypes::Link]
# Span::Blue.features << :membership
# Span::Blue.features << :comments
# Span::Blue.features << :collapsible_navigation
# Span::Blue.features << :content_modules
Span::Blue.features << :extra_page_code

# Span::Blue.features << :localization
# Span::Blue.locales = [:en, :es]

# Span::Blue.features << :collections
# Span::Blue.collections = [Article]

# Span::Blue.features << :tagging

# Page.allow_ssl = true


ActionController::Base.param_parsers.delete(Mime::XML) 