# Codebook

## contrafluran-filters/\*.csv

A file for each study OR.

- or.id: integer, Id of OR.
- agc.id: character, Id of anaesthetic gas canister (AGC), e.g CH0100022345
- agc.number: integer, number of AGC (own Id).
- start: POSIXct, date/time of AGC installation, should be YYYY-MM-DD HH:MM.
- end: POSIXct, date/time of AGC removal, should be YYYY-MM-DD HH:MM.


## corrections/\*.csv

A file for each study OR.

Same format as normal CRF. Will be used to overwrite/correct automatically
generated CRFs.

- center.id: id of the center.
- or.id: id of the operating room.
- agc.id: id of the anaesthetic gas canister (AGC).
- agc.number: number (study related) of the AGC (starts with 1 per or.id)
- bottle.number: number (study related) of the sevoflurane bottle (could be 1 to 10).
- start: date/time of anaesthesia start, should be YYYY-MM-DD HH:MM.
- end: date/time of anaesthesia end, should be YYYY-MM-DD HH:MM.
- balanced.anaesthesia: volatile anaesthetic used (1 = TRUE, 0 = FALSE).
- flow: fresh gas flow, 0.2 to 20.0.
- airway: tube or laryngeal mask (character, T or L).
- laparoscopic: laparoscopic surgery (1 = TRUE, 0 = FALSE).
- comments: free text comments.

## logbooks/

A folder for each study OR, containing multiple Draeger logbooks as txt.
Additionally each folder contains a `devices.csv` storing the period
the anaesthesia machine was used in this OR:

- device: character, device name.
- start: date/time of device start, should be YYYY-MM-DD HH:MM.
- end: date/time of device end, should be YYYY-MM-DD HH:MM.

## sevoflurane-bottles/\*.csv

A file for each study OR.

- or.id: integer, Id of OR.
- bottle.number: integer, number of sevoflurane bottle.
- start: POSIXct, date/time of bottle opening, should be YYYY-MM-DD HH:MM.
- end: POSIXct, date/time of empty bottle, should be YYYY-MM-DD HH:MM.


