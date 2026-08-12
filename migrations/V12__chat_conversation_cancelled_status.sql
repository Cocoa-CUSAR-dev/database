-- Adds 'cancelled' to chat.conversation's allowed status values.
--
-- A farmer stuck retrying a submission that could never succeed (an
-- unsupported handler) had no way out other than retrying forever -- the
-- confirm/retry prompt now offers a cancel button too, which needs a real
-- terminal status distinct from 'completed' (nothing was saved) and
-- distinct from 'active' (so a farmer isn't blocked from starting a fresh
-- conversation for the same task -- the "find my active conversation"
-- lookup filters on status = 'active').

ALTER TABLE chat.conversation DROP CONSTRAINT ck_chat_conversation_status;

ALTER TABLE chat.conversation
    ADD CONSTRAINT ck_chat_conversation_status
    CHECK (status IN ('active', 'paused', 'completed', 'cancelled'));
