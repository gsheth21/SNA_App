library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinycssloaders)

library(igraph)
library(visNetwork)
library(ggraph)
library(ggplot2)
library(graphlayouts)
library(RColorBrewer)
library(ggrepel)

library(tidytext)
library(widyr)
library(DT)
library(dplyr)
library(tidyr)
library(stringr)
library(tibble)
library(plotly)
library(scales)

library(here)

# Options
options(shiny.maxRequestSize = 30 * 1024^2)
options(warn = -1)

# Null-coalescing operator
`%||%` <- function(a, b) if (is.null(a)) b else a

# ============================================================
# Declaration of Independence text (shortened teaching version)
# ============================================================
declaration_text <- "
When in the Course of human events, it becomes necessary for one people to dissolve the political bands which have connected them with another, and to assume among the powers of the earth, the separate and equal station to which the Laws of Nature and of Nature's God entitle them, a decent respect to the opinions of mankind requires that they should declare the causes which impel them to the separation.

We hold these truths to be self-evident, that all men are created equal, that they are endowed by their Creator with certain unalienable Rights, that among these are Life, Liberty and the pursuit of Happiness. That to secure these rights, Governments are instituted among Men, deriving their just powers from the consent of the governed. That whenever any Form of Government becomes destructive of these ends, it is the Right of the People to alter or to abolish it, and to institute new Government.

The history of the present King of Great Britain is a history of repeated injuries and usurpations, all having in direct object the establishment of an absolute Tyranny over these States.

He has refused his Assent to Laws, the most wholesome and necessary for the public good.
He has forbidden his Governors to pass Laws of immediate and pressing importance.
He has dissolved Representative Houses repeatedly, for opposing with manly firmness his invasions on the rights of the people.
He has obstructed the Administration of Justice.
He has kept among us, in times of peace, Standing Armies without the Consent of our legislatures.
He has combined with others to subject us to a jurisdiction foreign to our constitution.
For imposing Taxes on us without our Consent.
For depriving us in many cases, of the benefits of Trial by Jury.

We, therefore, the Representatives of the united States of America, in General Congress, Assembled, do publish and declare, That these United Colonies are, and of Right ought to be Free and Independent States; that they are Absolved from all Allegiance to the British Crown, and that all political connection between them and the State of Great Britain, is and ought to be totally dissolved; and that as Free and Independent States, they have full Power to levy War, conclude Peace, contract Alliances, establish Commerce, and to do all other Acts and Things which Independent States may of right do.
"

# ============================================================
# Default custom stopwords (from chapter example)
# ============================================================
default_custom_stops <- c("us", "among", "shall", "may", "one")
