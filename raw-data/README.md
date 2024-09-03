# Codebook for raw-data

## crfs/*.csv

A file for each center/or combination.

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

## weights/*.csv

Initial weights of AGCs not used in this study to estimate weight gain of study
AGCs (substract the median weight of these AGCs from the reported weight of the
exhausted study AGCs).
The AGCs were closed with the "red cap" when the initial weight was measured.

- agc.id: id of the anaesthetic gas canister (AGC).
- initial.weight: initial weight of the unused AGC.

## setting.csv

- center.id: id of the center.
- or.id: id of the operating room.
- comments: free text comments.

