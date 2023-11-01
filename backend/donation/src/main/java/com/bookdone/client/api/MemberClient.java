package com.bookdone.client.api;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@FeignClient(name = "member-service", url = "${FeignClient.url}")
public interface MemberClient {
    @GetMapping("/members/{memberId}")
    ResponseEntity<?> getMemberInfo(@PathVariable long memberId);

    @GetMapping("/members")
    ResponseEntity<?> getMemberInfoList(List<Long> memberIdList);
}
