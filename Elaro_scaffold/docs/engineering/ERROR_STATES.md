# Error & Empty States

- Library load fail → fall back to bundled seed JSON
- Core Data save fail → retry with backoff; toast error
- CloudKit denied → remain local; explain toggle
- Empty child list → CTA “Add your first child”
