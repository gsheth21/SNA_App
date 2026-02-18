# Create "Work in Progress" placeholder box
create_wip_box <- function(chapter_name, topics, coming_soon_text = "Coming soon!") {
  box(
    title = "🚧 Work in Progress",
    width = 12,
    solidHeader = TRUE,
    status = "warning",
    
    h3(paste(chapter_name, "Chapter - Under Development")),
    
    p("This section will cover:", style = "font-size: 16px; margin-top: 15px;"),
    
    tags$ul(
      lapply(topics, function(topic) {
        tags$li(topic, style = "font-size: 14px; margin-bottom: 5px;")
      })
    ),
    
    hr(),
    
    p(strong(coming_soon_text), 
      style = "font-size: 18px; color: #CC0000; text-align: center; margin-top: 20px;"),
    
    p("In the meantime, please explore the Overview and Simulation chapters.", 
      style = "text-align: center; color: #666;")
  )
}

# Create info box with icon
create_info_box <- function(title, value, icon_name, color = "red") {
  infoBox(
    title = title,
    value = value,
    icon = icon(icon_name),
    color = color,
    fill = TRUE,
    width = 3
  )
}

# Create value box with subtitle
create_value_box <- function(value, subtitle, icon_name, color = "red") {
  valueBox(
    value = value,
    subtitle = subtitle,
    icon = icon(icon_name),
    color = color,
    width = 3
  )
}

# Create collapsible info panel
create_info_panel <- function(title, content, collapsed = TRUE) {
  box(
    title = title,
    width = 12,
    solidHeader = TRUE,
    status = "info",
    collapsible = TRUE,
    collapsed = collapsed,
    content
  )
}

# Create statistics list
create_stats_list <- function(stats_named_vector) {
  tags$ul(
    lapply(names(stats_named_vector), function(name) {
      tags$li(
        strong(paste0(name, ": ")),
        stats_named_vector[[name]]
      )
    })
  )
}

# Create attribute selector
create_attribute_selector <- function(input_id, label, attributes, selected = NULL, multiple = FALSE) {
  if (length(attributes) == 0) {
    return(p("No attributes available", style = "padding-left: 15px; color: #999;"))
  }
  
  selectInput(
    inputId = input_id,
    label = label,
    choices = c("None", attributes),
    selected = selected %||% "None",
    multiple = multiple
  )
}

# Create download button with custom styling
create_download_button <- function(output_id, label = "Download Data", icon_name = "download") {
  downloadButton(
    outputId = output_id,
    label = label,
    icon = icon(icon_name),
    class = "btn-danger"  # NC State red
  )
}

# Create action button with NC State styling
create_action_button <- function(input_id, label, icon_name = NULL, color = "danger") {
  if (!is.null(icon_name)) {
    actionButton(
      inputId = input_id,
      label = label,
      icon = icon(icon_name),
      class = paste0("btn-", color),
      style = "width: 100%;"
    )
  } else {
    actionButton(
      inputId = input_id,
      label = label,
      class = paste0("btn-", color),
      style = "width: 100%;"
    )
  }
}

# Create section header
create_section_header <- function(title, subtitle = NULL) {
  tagList(
    h3(title, style = "color: #CC0000; font-weight: bold; margin-bottom: 5px;"),
    if (!is.null(subtitle)) {
      p(subtitle, style = "color: #666; font-size: 14px; margin-top: 0;")
    }
  )
}

# Create help tooltip
create_help_tooltip <- function(text, tooltip_text) {
  tags$span(
    text,
    title = tooltip_text,
    `data-toggle` = "tooltip",
    style = "cursor: help; border-bottom: 1px dotted #999;"
  )
}

# Create legend box
create_legend_box <- function(legend_data, title = "Legend") {
  box(
    title = title,
    width = 12,
    solidHeader = TRUE,
    status = "info",
    
    if (is.data.frame(legend_data)) {
      DT::datatable(
        legend_data,
        options = list(
          dom = 't',
          pageLength = 100,
          ordering = FALSE
        ),
        rownames = FALSE
      )
    } else if (is.list(legend_data)) {
      tags$ul(
        lapply(names(legend_data), function(name) {
          tags$li(
            strong(paste0(name, ": ")),
            legend_data[[name]]
          )
        })
      )
    } else {
      p(legend_data)
    }
  )
}

# Create parameter control panel
create_param_panel <- function(title, controls) {
  box(
    title = title,
    width = 12,
    solidHeader = TRUE,
    status = "primary",
    collapsible = TRUE,
    controls
  )
}

# Create results display box
create_results_box <- function(title, output_ui, width = 12) {
  box(
    title = title,
    width = width,
    solidHeader = TRUE,
    status = "success",
    output_ui
  )
}

# Create tabbed content box
create_tabbed_box <- function(title, tab_panels, width = 12) {
  tabBox(
    title = title,
    width = width,
    !!!tab_panels  # Unpack list of tabPanels
  )
}

# Format p-value for display
format_pvalue <- function(p) {
  if (p < 0.001) {
    return("< 0.001 ***")
  } else if (p < 0.01) {
    return(paste0(round(p, 3), " **"))
  } else if (p < 0.05) {
    return(paste0(round(p, 3), " *"))
  } else {
    return(paste0(round(p, 3), " (ns)"))
  }
}

# Format number for display
format_number <- function(x, digits = 3) {
  if (is.na(x)) return("N/A")
  if (is.infinite(x)) return("∞")
  return(round(x, digits))
}

# Create metric card
create_metric_card <- function(metric_name, value, description = NULL, color = "red") {
  valueBoxOutput <- valueBox(
    value = value,
    subtitle = metric_name,
    icon = icon("chart-line"),
    color = color,
    width = 4
  )
  
  if (!is.null(description)) {
    tagList(
      valueBoxOutput,
      p(description, style = "font-size: 12px; color: #666; padding: 0 15px;")
    )
  } else {
    valueBoxOutput
  }
}