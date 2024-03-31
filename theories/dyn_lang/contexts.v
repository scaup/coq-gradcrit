From main.prelude Require Import imports autosubst.
From main.dyn_lang Require Import definition.

Inductive ctx_item :=
  | CTX_Lam
  | CTX_AppL (ℓ : label) (e2 : expr)
  | CTX_AppR (ℓ : label) (e1 : expr)
  | CTX_PairL (e2 : expr)
  | CTX_PairR (e1 : expr)
  | CTX_Fst (ℓ : label)
  | CTX_Snd (ℓ : label)
  | CTX_InjL
  | CTX_InjR
  | CTX_CaseL (ℓ : label) (e1 : expr) (e2 : expr)
  | CTX_CaseM (ℓ : label) (e0 : expr) (e2 : expr)
  | CTX_CaseR (ℓ : label) (e0 : expr) (e1 : expr)
  | CTX_BinOpL (ℓ : label) (op : bin_op) (e2 : expr)
  | CTX_BinOpR (ℓ : label) (op : bin_op) (e1 : expr)
  | CTX_IfL (ℓ : label) (e1 : expr) (e2 : expr)
  | CTX_IfM (ℓ : label) (e0 : expr) (e2 : expr)
  | CTX_IfR (ℓ : label) (e0 : expr) (e1 : expr)
  | CTX_SeqL (ℓ : label) (e2 : expr)
  | CTX_SeqR (ℓ : label) (e1 : expr).

Definition fill_ctx_item (ctx : ctx_item) (e : expr) : expr :=
  match ctx with
  | CTX_Lam => Lam e
  | CTX_AppL ℓ e2 => App ℓ e e2
  | CTX_AppR ℓ e1 => App ℓ e1 e
  | CTX_PairL e2 => Pair e e2
  | CTX_PairR e1 => Pair e1 e
  | CTX_Fst ℓ => Fst ℓ e
  | CTX_Snd ℓ => Snd ℓ e
  | CTX_InjL => InjL e
  | CTX_InjR => InjR e
  | CTX_CaseL ℓ e1 e2 => Case ℓ e e1 e2
  | CTX_CaseM ℓ e0 e2 => Case ℓ e0 e e2
  | CTX_CaseR ℓ e0 e1 => Case ℓ e0 e1 e
  | CTX_BinOpL ℓ op e2 => BinOp ℓ op e e2
  | CTX_BinOpR ℓ op e1 => BinOp ℓ op e1 e
  | CTX_IfL ℓ e1 e2 => If ℓ e e1 e2
  | CTX_IfM ℓ e0 e2 => If ℓ e0 e e2
  | CTX_IfR ℓ e0 e1 => If ℓ e0 e1 e
  | CTX_SeqL ℓ e2 => Seq ℓ e e2
  | CTX_SeqR ℓ e1 => Seq ℓ e1 e
  end.

Notation ctx := (list ctx_item).

Definition fill_ctx (C : ctx) (e : expr) : expr :=
 foldr fill_ctx_item e C.

Lemma fill_ctx_app e K K' : fill_ctx K' (fill_ctx K e) = fill_ctx (K' ++ K) e.
Proof. revert K. induction K' => K; simpl; auto. by rewrite IHK'. Qed.

(*   Inductive typed_ctx_item : *)
(*       ctx_item → list type → type → list type → type → Prop := *)
(*     | TP_CTX_Lam Γ τ τ' : *)
(*       typed_ctx_item CTX_Lam (τ :: Γ) τ' Γ (TArrow τ τ') *)
(*     | TP_CTX_AppL Γ e2 τ τ' : *)
(*       typed Γ e2 τ → *)
(*       typed_ctx_item (CTX_AppL e2) Γ (TArrow τ τ') Γ τ' *)
(*     | TP_CTX_AppR Γ e1 τ τ' : *)
(*       typed Γ e1 (TArrow τ τ') → *)
(*       typed_ctx_item (CTX_AppR e1) Γ τ Γ τ' *)
(*     | TP_CTX_LetInL Γ e2 τ τ' : *)
(*         typed (τ :: Γ) e2 τ' → *)
(*         typed_ctx_item (CTX_LetInL e2) Γ τ Γ τ' *)
(*     | TP_CTX_LetInR Γ e1 τ τ' : *)
(*         typed Γ e1 τ → *)
(*         typed_ctx_item (CTX_LetInR e1) (τ :: Γ) τ' Γ τ' *)
(*     | TP_CTX_PairL Γ e2 τ τ' : *)
(*       typed Γ e2 τ' → *)
(*       typed_ctx_item (CTX_PairL e2) Γ τ Γ (TProd τ τ') *)
(*     | TP_CTX_PairR Γ e1 τ τ' : *)
(*       typed Γ e1 τ → *)
(*       typed_ctx_item (CTX_PairR e1) Γ τ' Γ (TProd τ τ') *)
(*     | TP_CTX_Fst Γ τ τ' : *)
(*       typed_ctx_item CTX_Fst Γ (TProd τ τ') Γ τ *)
(*     | TP_CTX_Snd Γ τ τ' : *)
(*       typed_ctx_item CTX_Snd Γ (TProd τ τ') Γ τ' *)
(*     | TP_CTX_InjL Γ τ τ' : *)
(*       typed_ctx_item CTX_InjL Γ τ Γ (TSum τ τ') *)
(*     | TP_CTX_InjR Γ τ τ' : *)
(*       typed_ctx_item CTX_InjR Γ τ' Γ (TSum τ τ') *)
(*     | TP_CTX_CaseL Γ e1 e2 τ1 τ2 τ' : *)
(*       typed (τ1 :: Γ) e1 τ' → typed (τ2 :: Γ) e2 τ' → *)
(*       typed_ctx_item (CTX_CaseL e1 e2) Γ (TSum τ1 τ2) Γ τ' *)
(*     | TP_CTX_CaseM Γ e0 e2 τ1 τ2 τ' : *)
(*       typed Γ e0 (TSum τ1 τ2) → typed (τ2 :: Γ) e2 τ' → *)
(*       typed_ctx_item (CTX_CaseM e0 e2) (τ1 :: Γ) τ' Γ τ' *)
(*     | TP_CTX_CaseR Γ e0 e1 τ1 τ2 τ' : *)
(*       typed Γ e0 (TSum τ1 τ2) → typed (τ1 :: Γ) e1 τ' → *)
(*       typed_ctx_item (CTX_CaseR e0 e1) (τ2 :: Γ) τ' Γ τ' *)
(*     | TP_CTX_IfL Γ e1 e2 τ : *)
(*       typed Γ e1 τ → typed Γ e2 τ → *)
(*       typed_ctx_item (CTX_IfL e1 e2) Γ (TBool) Γ τ *)
(*     | TP_CTX_IfM Γ e0 e2 τ : *)
(*       typed Γ e0 (TBool) → typed Γ e2 τ → *)
(*       typed_ctx_item (CTX_IfM e0 e2) Γ τ Γ τ *)
(*     | TP_CTX_IfR Γ e0 e1 τ : *)
(*       typed Γ e0 (TBool) → typed Γ e1 τ → *)
(*       typed_ctx_item (CTX_IfR e0 e1) Γ τ Γ τ *)
(*     | TP_CTX_BinOpL op Γ e2 : *)
(*       typed Γ e2 TInt → *)
(*       typed_ctx_item (CTX_BinOpL op e2) Γ TInt Γ (binop_res_type op) *)
(*     | TP_CTX_BinOpR op e1 Γ : *)
(*       typed Γ e1 TInt → *)
(*       typed_ctx_item (CTX_BinOpR op e1) Γ TInt Γ (binop_res_type op) *)
(*     | TP_CTX_Fold Γ τ : *)
(*       typed_ctx_item CTX_Fold Γ τ.[(TRec τ)/] Γ (TRec τ) *)
(*     | TP_CTX_Unfold Γ τ : *)
(*       typed_ctx_item CTX_Unfold Γ (TRec τ) Γ τ.[(TRec τ)/]. *)

(*   Lemma typed_ctx_item_typed k Γ τ Γ' τ' e : *)
(*     typed Γ e τ → typed_ctx_item k Γ τ Γ' τ' → *)
(*     typed Γ' (fill_ctx_item k e) τ'. *)
(*   Proof. induction 2; simpl; eauto using typed. Qed. *)

(* End context_depth_one. *)

(* Section context. *)

(*   Definition ctx := (list ctx_item). *)

(*   (* Does not define fill convention as in ectxi_language! *) *)
(*   Definition fill_ctx (K : ctx) (e : expr) : expr := foldr (fill_ctx_item) e K. *)

(*   Lemma fill_ctx_behavior Ki K e : fill_ctx (Ki :: K) e = fill_ctx_item Ki (fill_ctx K e). *)
(*   Proof. by simpl. Qed. *)

(*   Inductive typed_ctx : ctx → list type → type → list type → type → Prop := *)
(*     | TPCTX_nil Γ τ : *)
(*       typed_ctx nil Γ τ Γ τ *)
(*     | TPCTX_cons Γ1 τ1 Γ2 τ2 Γ3 τ3 k K : *)
(*       typed_ctx_item k Γ2 τ2 Γ3 τ3 → *)
(*       typed_ctx K Γ1 τ1 Γ2 τ2 → *)
(*       typed_ctx (k :: K) Γ1 τ1 Γ3 τ3. *)

(*   Lemma typed_ctx_typed K Γ τ Γ' τ' e : *)
(*     typed Γ e τ → typed_ctx K Γ τ Γ' τ' → typed Γ' (fill_ctx K e) τ'. *)
(*   Proof. induction 2; simpl; eauto using typed_ctx_item_typed. Qed. *)

(*   Lemma fill_ctx_app e K K' : fill_ctx K' (fill_ctx K e) = fill_ctx (K' ++ K) e. *)
(*   Proof. revert K. induction K' => K; simpl; auto. by rewrite IHK'. Qed. *)

(*   (* Alternative that follows the convention *) *)
(*   Definition fill_ctx' (K : ctx) (e : expr) : expr := foldl (flip fill_ctx_item) e K. *)

(*   Lemma fill_ctx'_behavior Ki e K : (fill_ctx' (Ki :: K) e = fill_ctx' K (fill_ctx_item Ki e)). *)
(*   Proof. by simpl. Qed. *)

(* End context. *)

(* Local Notation "|C> Γr ⊢ₙₒ C ☾ Γh ; τh ☽ : τr" := (typed_ctx C Γh τh Γr τr) (at level 74, Γr, C, Γh, τh, τr at next level). *)
(* Local Notation "|Ci> Γr ⊢ₙₒ C ☾ Γh ; τh ☽ : τr" := (typed_ctx_item C Γh τh Γr τr) (at level 74, Γr, C, Γh, τh, τr at next level). *)

(* Lemma typed_expr_append Γ e τ τs : *)
(*   Γ ⊢ₙₒ e : τ → Γ ++ τs ⊢ₙₒ e : τ. *)
(* Proof. *)
(*   intro H. *)
(*   replace e with (e.[upn (length Γ) (ren (+ (length τs)))]). *)
(*   replace (Γ ++ τs) with (Γ ++ τs ++ []) by by rewrite app_nil_r. *)
(*   apply context_gen_weakening. by rewrite app_nil_r. *)
(*   by eapply typed_n_closed. *)
(* Qed. *)

(* Lemma typed_ctx_item_append C Γ τ Γ' τ' τs : *)
(*   |Ci> Γ' ⊢ₙₒ C ☾ Γ ; τ ☽ : τ' → *)
(*   |Ci> Γ' ++ τs ⊢ₙₒ C ☾ Γ ++ τs ; τ ☽ : τ'. *)
(* Proof. *)
(*   intro H. destruct H; try econstructor; try by apply typed_expr_append. *)
(*   change (τ :: Γ ++ τs ) with ((τ :: Γ) ++ τs). by apply typed_expr_append. *)
(*   change (τ1 :: Γ ++ τs ) with ((τ1 :: Γ) ++ τs). by apply typed_expr_append. *)
(*   change (τ2 :: Γ ++ τs ) with ((τ2 :: Γ) ++ τs). by apply typed_expr_append. *)
(*   change (τ2 :: Γ ++ τs ) with ((τ2 :: Γ) ++ τs). by apply typed_expr_append. *)
(*   change (τ1 :: Γ ++ τs ) with ((τ1 :: Γ) ++ τs). by apply typed_expr_append. *)
(* Qed. *)

(* Lemma typed_ctx_append C Γ τ Γ' τ' τs : *)
(*   |C> Γ' ⊢ₙₒ C ☾ Γ ; τ ☽ : τ' → *)
(*   |C> Γ' ++ τs ⊢ₙₒ C ☾ Γ ++ τs ; τ ☽ : τ'. *)
(* Proof. *)
(*   intro H. *)
(*   induction H. *)
(*   - constructor. *)
(*   - econstructor. 2: eapply IHtyped_ctx. *)
(*     by apply typed_ctx_item_append. *)
(* Qed. *)

(* Lemma typed_ctx_app Γ Γ' Γ'' K K' τ τ' τ'' : *)
(*   |C> Γ'' ⊢ₙₒ K' ☾ Γ' ; τ' ☽ : τ'' → *)
(*   |C> Γ' ⊢ₙₒ K ☾ Γ ; τ ☽ : τ' → *)
(*   |C> Γ'' ⊢ₙₒ (K' ++ K) ☾ Γ ; τ ☽ : τ''. *)
(* Proof. *)
(*   revert K Γ Γ' Γ'' τ τ' τ''; induction K' => K Γ Γ' Γ'' τ τ' τ''; simpl. *)
(*   - by inversion 1; subst. *)
(*   - intros Htc1 Htc2. inversion Htc1; subst. *)
(*     econstructor; last eapply IHK'; eauto. *)
(* Qed. *)