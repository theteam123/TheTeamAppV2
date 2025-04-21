/*
  # Set up RLS policies for all tables

  This migration adds additional RLS policies to ensure proper data access control.

  1. Security Updates
    - Add RLS policies for all tables
    - Add policies for CRUD operations
    - Ensure company-based data isolation

  2. Changes
    - Add RLS policies for documents
    - Add RLS policies for forms
    - Add RLS policies for tags
    - Add RLS policies for categories
    - Add RLS policies for form submissions
*/

-- Policies for documents
CREATE POLICY "Users can create company documents"
  ON documents FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = documents.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update company documents"
  ON documents FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = documents.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete company documents"
  ON documents FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = documents.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

-- Policies for forms
CREATE POLICY "Users can create company forms"
  ON forms FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = forms.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update company forms"
  ON forms FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = forms.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete company forms"
  ON forms FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = forms.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

-- Policies for tags
CREATE POLICY "Users can create company tags"
  ON tags FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = tags.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view company tags"
  ON tags FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = tags.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update company tags"
  ON tags FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = tags.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete company tags"
  ON tags FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = tags.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

-- Policies for categories
CREATE POLICY "Users can create company categories"
  ON categories FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = categories.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view company categories"
  ON categories FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = categories.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update company categories"
  ON categories FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = categories.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete company categories"
  ON categories FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_companies
      WHERE user_companies.company_id = categories.company_id
      AND user_companies.user_id = auth.uid()
    )
  );

-- Policies for form submissions
CREATE POLICY "Users can create form submissions"
  ON form_submissions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM forms
      WHERE forms.id = form_submissions.form_id
      AND (
        forms.is_public = true
        OR EXISTS (
          SELECT 1 FROM user_companies
          WHERE user_companies.company_id = forms.company_id
          AND user_companies.user_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "Public users can submit to public forms"
  ON form_submissions FOR INSERT
  TO anon
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM forms
      WHERE forms.id = form_submissions.form_id
      AND forms.is_public = true
    )
  );

CREATE POLICY "Users can delete company form submissions"
  ON form_submissions FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM forms
      JOIN user_companies ON user_companies.company_id = forms.company_id
      WHERE forms.id = form_submissions.form_id
      AND user_companies.user_id = auth.uid()
    )
  );

-- Policies for public submitters
CREATE POLICY "Anyone can create public submitter profiles"
  ON public_submitters FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Users can view public submitter profiles"
  ON public_submitters FOR SELECT
  TO authenticated
  USING (true);