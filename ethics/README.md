# Reference ODT

- has to be odt (docx is not supported)
- generate reference

```
pandoc -o pandoc/reference/reference.odt --print-default-data-file reference.odt
```

## Variables in header/footer

- *Datei-\>Eigenschaften-\>Benutzerdefiniert* (File-\>Properties-\>User defined)
- *Feld* einfügen (insert field), *benutzerdefiniert* (user defined).
- Define field name as variable in YAML header

See also: https://github.com/jgm/pandoc/issues/2839
