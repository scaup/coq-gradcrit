From main.prelude Require Import imports labels autosubst.
(* From main.cast_calc Require Import types. *)
From main.dyn_lang Require Import definition lemmas labels.
From main.logrel Require Import definition lib.rfn lib.weakestpre.

From iris.si_logic Require Export bi.
From iris.proofmode Require Import tactics.

Definition RefineL (L : LabelRel) (e e' : expr) : Prop :=
  ((∃ v, rtc step e (of_val v)) → (∃ v', rtc step e' (of_val v'))) ∧
  (∀ ℓ, rtc step e (Error ℓ) → ∃ ℓ', L ℓ ℓ' ∧ rtc step e' (Error ℓ')).

Lemma logrel_adequacy L e e' τ
  (H : open_exprel_typed [] L e e' τ) :
    RefineL L e e'.
Proof.
  rewrite /open_exprel_typed /exprel_typed /rfn in H.
  specialize (H L (le_permissive_refl_inst L) [] []). asimpl in H.
  rewrite /val_lift_r /lbl_lift_r in H.
  assert (H' : ⊢ wp (fun v => ⌜∃ v', rtc step_ne e' (of_val v')⌝)
                    (fun ℓ => ⌜∃ t' ℓ', rtc step_ne e' t' ∧ faulty t' ℓ' ∧ L ℓ ℓ'⌝) e).
  { iApply wp_impl. iApply H; auto. auto. iIntros (v) "H".
    iDestruct "H" as (v') "[%H' _]". eauto. } clear H.
  assert (H := wp_adequacy _ _ _ H'). clear H'.
  split.
  - destruct H as [H _]. intros Hev. destruct Hev as [v Hev].
    rewrite rtc_step_step_ne_to_val in Hev.
    destruct (H _ Hev) as [v' G].
    rewrite -rtc_step_step_ne_to_val in G. eauto.
  - destruct H as [_ H]. intros ℓ Heℓ.
    destruct (iffLR (rtc_step_step_ne_to_error _ _) Heℓ) as (t' & Htℓ & et'). clear Heℓ.
    specialize (H t' ℓ Htℓ et'). destruct H as (t'' & ℓ' & He't'' & Hf & HL).
    exists ℓ'. split; auto. apply rtc_step_step_ne_to_error. eauto.
Qed.

From main.dyn_lang Require Import contexts.

Lemma logrel_adequacy_alt L Γ e e' τ (H : open_exprel_typed Γ L e e' τ) :
  ∀ C C' M τ' (HCC' : ctx_rel_typed M C C' Γ τ [] τ'),
    RefineL (L ⊔ M) (fill_ctx C e) (fill_ctx C' e').
Proof.
  intros. eapply logrel_adequacy. apply HCC'.
  apply le_permissive_join_r.
  eapply open_exprel_typed_weaken; eauto.
  apply le_permissive_join_l.
Qed.

Lemma refineL_trans (L L' : LabelRel) {Lf} {e1} e2 {e3}
  (Hf : L ⋅ L' ⊑ Lf)
  (H12 : RefineL L e1 e2) (H23 : RefineL L' e2 e3) :
  RefineL Lf e1 e3.
Proof.
  split.
  - destruct H12 as [R12 _]; destruct H23 as [R23 _].
    intro H1. apply R23. apply R12. apply H1.
  - destruct H12 as [_ R12]; destruct H23 as [_ R23]. intros ℓ1 H1.
    destruct (R12 ℓ1 H1) as (ℓ2 & L12 & H2). clear R12.
    destruct (R23 ℓ2 H2) as (ℓ3 & L23 & H3). clear R23.
    exists ℓ3. split; auto. apply Hf. exists ℓ2. split; auto.
Qed.

Notation "e ≤{ L } e' " := (RefineL L e e') (at level 10).

Definition EquiBehaveL (L : label → Prop) (e e' : expr) : Prop :=
    e ≤{diagonal L} e' ∧ e' ≤{diagonal L} e.

Notation "e ≡{ L } e' " := (EquiBehaveL L e e') (at level 10).

Lemma RefineL_weaken {L L' e e'} :
  RefineL L e e' →
  (L ⊑ L') →
  RefineL L' e e'.
Proof. intros; destruct H. split; naive_solver. Qed.

From main.cast_calc Require Import types.

(* "logical label-aware ctx refinement" *)
Definition lla_ctx_refinement (Γ : list type) (P : label -> Prop) (e e' : expr) (τ : type) : Prop :=
  ∀ C M τ' (HCC' : ctx_rel_typed (diagonal M) C C Γ τ [] τ'),
      (fill_ctx C e) ≤{ (diagonal P) ⊔ (diagonal M) } (fill_ctx C e').

(* Notation open_exprel_typed_cl := lla_ctx_refinement. *)

Lemma lla_ctx_refinement_weaken (Γ : list type) (P P' : label -> Prop) (e e' : expr) (τ : type) :
    lla_ctx_refinement Γ P e e' τ →
    (∀ ℓ, P ℓ → P' ℓ) →
    lla_ctx_refinement Γ P' e e' τ.
Proof.
  intros H HPP' C M τ' HC. eapply RefineL_weaken. eapply H. apply HC.
  intros ℓ ℓ' Hℓℓ'. destruct Hℓℓ'. left. destruct H0. simplify_eq. split. auto. destruct H1. by split; apply HPP'.
  by right.
Qed.

Lemma lr_lla_ctx_refinement (Γ : list type) (P : label → Prop) (e e' : expr) (τ : type) :
    open_exprel_typed Γ (diagonal P) e e' τ → lla_ctx_refinement Γ P e e' τ.
Proof. intros H C M τ' HC. by eapply logrel_adequacy_alt. Qed.

Lemma lla_ctx_refinement_trans Γ P12 P23 e1 e2 e3 τ
  (H12 : lla_ctx_refinement Γ P12 e1 e2 τ)
  (H23 : lla_ctx_refinement Γ P23 e2 e3 τ) :
  lla_ctx_refinement Γ ((fun l => P12 l ∧ P23 l)) e1 e3 τ.
Proof.
  intros C M τ' HC.
  eapply refineL_trans; [| by eapply H12 | by eapply H23].
  rewrite /combine_LabelRel /=. rewrite /join /join_LabelRel_inst /join_LabelRel /diagonal.
  intros l l' H. naive_solver.
Qed.
