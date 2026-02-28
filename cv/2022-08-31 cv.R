

#
#devtools::install_github("nstrayer/datadrivencv")
library(datadrivencv)

# run ?datadrivencv::use_datadriven_cv to see more details

datadrivencv::use_datadriven_cv(
    full_name = "Nick Strayer",
    data_location = "https://docs.google.com/spreadsheets/d/14MQICF2F8-vf8CKPF1m4lyGKO6_thG-4aSwat1e2TWc",
    pdf_location = "https://github.com/nstrayer/cv/raw/master/strayer_cv.pdf",
    html_location = "nickstrayer.me/cv/",
    source_location = "https://github.com/nstrayer/cv"
)
