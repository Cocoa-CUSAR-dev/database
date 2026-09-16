-- Carry-forward for repeat submission ("one แปลง, many activities").
-- See cocoa-docs/docs/plans/carry-forward-design.md.
--
-- When a farmer adds another row to a multi-submit task, questions flagged
-- here are answered for them from the row they just submitted; the rest are
-- asked again. On the farm_activity form that means farm_id and plot_id
-- stick while farm_activity_type_id and the note are asked fresh -- so
-- logging three activities in one plot no longer re-asks "which farm, which
-- plot" three times.
--
-- Why a per-question flag rather than something inferred: the field that
-- varies (farm_activity_type_id) is an OPTION exactly like the two that
-- don't (farm_id, plot_id). No rule based on input type, name, or
-- nullability can tell "context that stays" from "payload that changes", so
-- it has to be authored. It is also what keeps the varying field in front
-- of the farmer: prefilling everything instead would land them on a
-- confirmation summary that is a one-tap duplicate of the row they just
-- filed.
--
-- NOT NULL DEFAULT false: every existing question keeps today's behaviour
-- (always asked). Opt-in only.

ALTER TABLE form.question
    ADD COLUMN IF NOT EXISTS carry_forward BOOLEAN NOT NULL DEFAULT FALSE;
