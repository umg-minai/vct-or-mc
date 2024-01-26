# Reference ODT

muss odt sein, da es mit docx nicht funktioniert

Referenzdokument erzeugen:

```
pandoc -o pandoc/reference/reference.odt --print-default-data-file reference.odt
```

## Variablen in Header/Footer

- Hinzufügen über *Datei->Eigenschaften->Benutzerdefiniert*.
- *Feld* einfügen, *benutzerdefiniert*
- Feldnamer als Variable in YAML-Header definieren

Siehe auch: https://github.com/jgm/pandoc/issues/2839
