# frozen_string_literal: true

module Castle
  # list of events based on https://docs.castle.io/api_reference/#list-of-recognized-events
  module Events
    # Record when a user successfully logs in.
    LOGIN_SUCCEEDED = '$login.succeeded'

    # Record when a user failed to log in.
    LOGIN_FAILED = '$login.failed'

    # Record when a user logs out.
    LOGOUT_SUCCEEDED = '$logout.succeeded'

    # Record when a user updated their profile (including password, email, phone, etc).
    PROFILE_UPDATE_SUCCEEDED = '$profile_update.succeeded'

    # Record errors when updating profile.
    PROFILE_UPDATE_FAILED = '$profile_update.failed'

    # Capture account creation, both when a user signs up as well as when created manually
    # by an administrator.
    REGISTRATION_SUCCEEDED = '$registration.succeeded'

    # Record when an account failed to be created.
    REGISTRATION_FAILED = '$registration.failed'

    # The user completed all of the steps in the password reset process and the password was
    # successfully reset.Password resets do not required knowledge of the current password.
    PASSWORD_RESET_SUCCEEDED = '$password_reset.succeeded'

    # Use to record when a user failed to reset their password.
    PASSWORD_RESET_FAILED = '$password_reset.failed'

    # The user successfully requested a password reset.
    PASSWORD_RESET_REQUEST_SUCCCEEDED = '$password_reset_request.succeeded'

    # The user failed to request a password reset.
    PASSWORD_RESET_REQUEST_FAILED = '$password_reset_request.failed'

    # User account has been reset.
    INCIDENT_MITIGATED = '$incident.mitigated'

    # User confirmed malicious activity.
    REVIEW_ESCALATED = '$review.escalated'

    # User confirmed safe activity.
    REVIEW_RESOLVED = '$review.resolved'

    # Record when a user is prompted with additional verification, such as two-factor
    # authentication or a captcha.
    CHALLENGE_REQUESTED = '$challenge.requested'

    # Record when additional verification was successful.
    CHALLENGE_SUCCEEDED = '$challenge.succeeded'

    # Record when additional verification failed.
    CHALLENGE_FAILED = '$challenge.failed'

    # Record when a user attempts an in-app transaction, such as a purchase or withdrawal.
    TRANSACTION_ATTEMPTED = '$transaction.attempted'

    # Record when a user session is extended, or use any time you want
    # to re-authenticate a user mid-session.
    SESSION_EXTENDED = '$session.extended'
  end
end
