overview_ui <- tagList(

  # Welcome box
  fluidRow(
    box(
      title       = "📖 Welcome to Text Network Analysis",
      width       = 12,
      solidHeader = TRUE,
      status      = "danger",
      h3("Text Networks — Chapter Overview"),
      p("This app walks through the complete workflow for building a word co-occurrence
        network from a text document, following the chapter step by step."),
      p("The analysis uses the ", strong("Declaration of Independence (1776)"),
        " as a teaching example because its clear rhetorical structure — political
        principles, a list of grievances, and a declaration of sovereignty — makes
        the network output easy to interpret."),
      hr(),
      tags$h4("🚀 How to use this app:"),
      tags$ol(
        tags$li("Read the ", strong("Overview"), " (you're here) for context on text networks"),
        tags$li("Follow ", strong("Text Prep"), " to see sentences, tokens, and stopword removal"),
        tags$li("Explore ", strong("Co-occurrence"), " to see which word pairs co-appear"),
        tags$li("Inspect the ", strong("Network"), " object stats"),
        tags$li("Study ", strong("Centrality"), " to find the most connected words"),
        tags$li("View the ", strong("Visualization"), " — interactive and static plots"),
        tags$li("Discover ", strong("Clusters"), " — semantic communities in the text")
      ),
      hr(),
      p(style = "font-size: 12px; color: #888;",
        "Use the sidebar to adjust extra stopwords, the number of top pairs to keep,
        and visual appearance options. Changes propagate through the entire pipeline.")
    )
  ),

  # What are text networks
  fluidRow(
    box(
      title       = "🔍 What Is a Text Network?",
      width       = 6,
      solidHeader = TRUE,
      collapsible = TRUE,
      collapsed   = FALSE,
      p("A text network is a graph in which ", strong("nodes represent words"),
        " and ", strong("edges represent co-occurrence"), " — two words are connected
        if they appear together in the same sentence (or paragraph, or window)."),
      p("The central value of text networks is that they reveal ", em("how meanings
        are organized"), ". Frequency lists tell you what appears often.
        A text network tells you how concepts cluster and which words bridge
        otherwise separate vocabularies."),
      tags$ul(
        tags$li(strong("Nodes:"), " content words (nouns, verbs, adjectives)"),
        tags$li(strong("Edges:"), " sentence-level co-occurrence"),
        tags$li(strong("Edge weight:"), " number of sentences the pair shares"),
        tags$li(strong("Stopwords removed:"), " function words that connect everything")
      )
    ),
    box(
      title       = "📜 About the Declaration of Independence",
      width       = 6,
      solidHeader = TRUE,
      collapsible = TRUE,
      collapsed   = FALSE,
      p("Thomas Jefferson's Declaration (1776) has three distinct rhetorical sections:"),
      tags$ol(
        tags$li(strong("Preamble:"), " abstract political philosophy (natural rights, consent of the governed)"),
        tags$li(strong("Grievances:"), " a list of British Crown violations ('He has...')"),
        tags$li(strong("Declaration:"), " sovereign separation and the assertion of independence")
      ),
      p("These sections draw on ", em("somewhat distinct vocabularies"), " that remain
        connected — making the document ideal for showing what a text network can
        reveal even for a single, short text."),
      hr(),
      uiOutput("overview_doc_stats")
    )
  ),

  # Workflow overview
  fluidRow(
    box(
      title       = "🗺️ Analysis Workflow",
      width       = 12,
      solidHeader = TRUE,
      collapsible = TRUE,
      collapsed   = FALSE,
      fluidRow(
        column(3,
          tags$div(class = "workflow-step",
            tags$h5("Step 1–2", style = "color: #CC0000;"),
            tags$p(strong("Load & Sentence-Split")),
            tags$p("The text is divided into sentences — the unit of co-occurrence context.",
                   style = "font-size: 12px;")
          )
        ),
        column(3,
          tags$div(class = "workflow-step",
            tags$h5("Step 3–4", style = "color: #CC0000;"),
            tags$p(strong("Tokenize & Clean")),
            tags$p("Words are extracted and stopwords are removed, leaving content terms.",
                   style = "font-size: 12px;")
          )
        ),
        column(3,
          tags$div(class = "workflow-step",
            tags$h5("Step 5–7", style = "color: #CC0000;"),
            tags$p(strong("Count Pairs → Graph")),
            tags$p("Word pairs that co-occur are counted and converted to an igraph object.",
                   style = "font-size: 12px;")
          )
        ),
        column(3,
          tags$div(class = "workflow-step",
            tags$h5("Step 8–10", style = "color: #CC0000;"),
            tags$p(strong("Centrality & Clusters")),
            tags$p("Central words are identified and semantic communities are detected.",
                   style = "font-size: 12px;")
          )
        )
      )
    )
  )
)
