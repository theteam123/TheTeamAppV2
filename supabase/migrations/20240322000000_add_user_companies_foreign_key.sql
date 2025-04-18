-- Add foreign key constraint from user_companies to profiles
ALTER TABLE user_companies
ADD CONSTRAINT fk_user_profiles
FOREIGN KEY (user_id) 
REFERENCES profiles(id)
ON DELETE CASCADE;

-- Add index to improve join performance
CREATE INDEX idx_user_companies_user_id ON user_companies(user_id);

-- Add comment to document the relationship
COMMENT ON CONSTRAINT fk_user_profiles ON user_companies IS 'Links user_companies.user_id to profiles.id, ensuring referential integrity'; 