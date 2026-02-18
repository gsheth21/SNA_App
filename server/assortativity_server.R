assortativity_server <- function(input, output, session, rv) {
  
  output$assortativity_attribute_select <- renderUI({
    req(rv$igraph)
    attrs <- vertex_attr_names(rv$igraph)
    attrs <- attrs[attrs != "name"]
    
    if (length(attrs) > 0) {
      radioButtons("assort_attribute", "Select Attribute:", 
                   choices = attrs, selected = attrs[1], inline = TRUE)
    } else {
      p("No categorical attributes available for assortativity analysis")
    }
  })
  
  output$mixing_attribute_select <- renderUI({
    req(rv$igraph)
    attrs <- vertex_attr_names(rv$igraph)
    attrs <- attrs[attrs != "name"]
    
    if (length(attrs) > 0) {
      selectInput("mixing_attribute", "Select Attribute:", 
                  choices = attrs, selected = attrs[1])
    } else {
      p("No categorical attributes available")
    }
  })
}