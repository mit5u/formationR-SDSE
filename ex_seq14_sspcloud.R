# install.packages(c("bookdown", "tidyverse", "dbplyr", "RPostgres", "RSQLite", "palmer.penguins"))
# install.packages("dbplot")

library(dbplyr)
library(tidyverse)
library(dbplot)

con <- DBI::dbConnect(RPostgres::Postgres(), 
                 user <- "user-jbeziau",
                 password = rstudioapi::askForPassword(paste0("Mot de passe de la base de données pour ", user)),
                 host = "postgresql-560901",
                 port = "5432",
                 dbname = "defaultdb")

copy_to(con, nycflights13::flights, "flights",
        temporary = FALSE, 
        indexes = list(
            c("year", "month", "day"), 
            "carrier", 
            "tailnum",
            "dest"
        )
)

flights_db <- tbl(con, "flights")
flights_db
flights_db %>% select(year:day, dep_delay, arr_delay)
flights_db %>% filter(dep_delay > 240)
flights_db %>% 
    group_by(dest) %>%
    summarise(delay = mean(dep_time))
tailnum_delay_db <- flights_db %>% 
    group_by(tailnum) %>%
    summarise(
        delay = mean(arr_delay),
        n = n()
    ) %>% 
    arrange(desc(delay)) %>%
    filter(n > 100)
tailnum_delay_db
tailnum_delay_db %>% show_query()
tailnum_delay_db %>% explain()

copy_to(con, mtcars)
mtcars <- tbl(con, "mtcars")
mtcars %>% 
    dbplot_bar(am, mean(mpg))
