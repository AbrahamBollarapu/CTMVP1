import pytest
from src.app.models.user_profile import list_profiles, create_or_update_profile, UserProfileInDB

def test_create_and_list():
    p = create_or_update_profile(1, 'freelancer', 10.0)
    assert isinstance(p, UserProfileInDB)
    assert p in list_profiles()
    assert p in list_profiles('freelancer')
