package com.bookdone.member.dto.request;

import com.bookdone.member.entity.Member;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class JoinMemberRequest {
    private String oauthId;
    private String nickname;

    public Member toEntity() {
        return Member
                .builder()
                .oauthId(oauthId)
                .nickname(nickname)
                .point(3)
                .fcmToken(null)
                .roles("USER_ROLE")
                .address("9999")
                .image("")
                .build();
    }
}
