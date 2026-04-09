setup_server <- function(id, rv, input, output, session) {
  
  # ── Tab 1: Data Overview ─────────────────────────────────────────────────────
  
  output$dataset_summary_ui <- renderUI({
    n_egos <- n_total_egos
    n_alters_total <- nrow(alterlong)
    n_edges_total <- sum(map_dbl(gr.list, igraph::ecount))
    n_alters_mean <- mean(alter_summary$n_alters)
    n_alters_min <- min(alter_summary$n_alters)
    n_alters_max <- max(alter_summary$n_alters)
    
    tagList(
      tags$ul(
        style = "font-size: 14px; line-height: 1.8;",
        tags$li(HTML(paste0("<strong>Number of Egos:</strong> ", n_egos))),
        tags$li(HTML(paste0("<strong>Total Alters:</strong> ", n_alters_total))),
        tags$li(HTML(paste0("<strong>Total Alter-Alter Edges:</strong> ", n_edges_total))),
        tags$li(HTML(paste0("<strong>Mean Alters per Ego:</strong> ", round(n_alters_mean, 2)))),
        tags$li(HTML(paste0("<strong>Range (Min-Max):</strong> ", n_alters_min, "-", n_alters_max, " alters per ego")))
      )
    )
  })

  output$egos_distribution_plot <- renderPlot({
    # Distribution of alters per ego
    ggplot(alter_summary, aes(x = n_alters)) +
      geom_histogram(bins = 6, fill = "#CC0000", color = "black", alpha = 0.7) +
      labs(title = "Distribution of Number of Alters per Ego",
           x = "Number of Alters", y = "Frequency") +
      theme_minimal() +
      theme(plot.title = element_text(face = "bold", size = 14))
  })

  output$alters_stats_ui <- renderUI({
    tagList(
      tags$ul(
        style = "font-size: 13px; line-height: 1.8;",
        tags$li(HTML(paste0("<strong>Min alters:</strong> ", min(alter_summary$n_alters)))),
        tags$li(HTML(paste0("<strong>Max alters:</strong> ", max(alter_summary$n_alters)))),
        tags$li(HTML(paste0("<strong>Mean:</strong> ", round(mean(alter_summary$n_alters), 2)))),
        tags$li(HTML(paste0("<strong>Median:</strong> ", median(alter_summary$n_alters)))),
        tags$li(HTML(paste0("<strong>SD:</strong> ", round(sd(alter_summary$n_alters), 2))))
      ),
      tags$br(),
      tags$p(
        HTML("<strong>Note:</strong> Max alters per ego depends on data collection design."),
        style = "color: #666; font-size: 12px; margin-top: 10px;"
      )
    )
  })

  # ── Tab 2: Ego Attributes Table ──────────────────────────────────────────────
  
  output$ego_attributes_table <- renderDT({
    # Dynamically select all columns from ego dataframe
    df <- ego_summary
    
    datatable(
      df,
      options = list(
        scrollX = TRUE,
        pageLength = 15,
        dom = 'lfrtip'
      )
    )
  })

  # ── Tab 3: Alter Attributes Table ────────────────────────────────────────────
  
  output$alter_attributes_table <- renderDT({
    # Dynamically get all columns from alterlong
    df <- alterlong |> as.data.frame()

    datatable(
      df,
      options = list(
        scrollX = TRUE,
        pageLength = 15,
        dom = 'lfrtip'
      )
    )
  })

  # ── Tab 4: Edgelist Table ────────────────────────────────────────────────────
  
  output$edges_table <- renderDT({
    # Extract edges from all igraph objects dynamically
    edges_all <- map_dfr(gr.list, function(g) {
      edge_list <- igraph::as_edgelist(g, names = TRUE)
      
      edges_df <- data.frame(
        from = edge_list[, 1],
        to = edge_list[, 2],
        stringsAsFactors = FALSE
      )
      
      # Add weight if available
      if ("weight" %in% igraph::edge_attr_names(g)) {
        edges_df$weight <- igraph::E(g)$weight
      }
      
      edges_df
    }, .id = "ego_id") |>
      mutate(ego_id = as.numeric(ego_id))
    
    datatable(
      edges_all,
      options = list(
        scrollX = TRUE,
        pageLength = 15,
        dom = 'lfrtip'
      ),
      colnames = c("Ego ID", "From (Alter)", "To (Alter)", "Weight")
    )
  })
}
