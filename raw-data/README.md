# Codebook for raw-data

## crf.csv

- center.id: id of the center.
- or.id: id of the operating room.
- agc.id: id of the anaesthetic gas canister (AGC).
- agc.number: number (study related) of the AGC (starts with 1 per or.id)
- bottle.number: number (study related) of the sevoflurane bottle (could be 1 to 10).
- date: date of anaesthesia, should be YYYY-mm-dd.
- start: time of anaesthesia start, should be HH:MM.
- end: time of anaesthesia end, should be HH:MM.
- balanced.anaesthesia: volatile anaesthetic used (1 = TRUE, 0 = FALSE).
- flow: fresh gas flow, 0.2 to 20.0.
- airway: tube or laryngeal mask (character, T or L).
- laparoscopic: laparoscopic surgery (1 = TRUE, 0 = FALSE).
- comments: free text comments.

## setting.csv

- center.id: id of the center.
- or.id: id of the operating room.
- comments: free text comments.

