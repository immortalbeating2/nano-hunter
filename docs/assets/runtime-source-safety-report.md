# Runtime Source Safety Report

This report blocks multi-project image_gen mix-ups for Nano Hunter runtime assets.

## Summary

- Status: `runtime_sources_confirmed`
- Runtime assets: `30`
- Review-required runtime assets: `0`
- Unsafe assets: `0`

## Runtime Gate Counts

- `runtime_reference_source_confirmed`: `30`

## Review Required

- None

## Policy

- `runtime_reference_source_confirmed` assets may stay in preview/runtime binding.
- `runtime_reference_derivation_review_required` assets must be treated as temporary preview until selected-source derivation is recorded or regenerated.
- `runtime_reference_source_review_required` assets must not be described as final runtime art; regenerate or manually confirm before final binding.
- `planned_replacement_*_review_required` assets must be fixed before being newly bound into scenes.
