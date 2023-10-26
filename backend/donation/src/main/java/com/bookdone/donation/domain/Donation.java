package com.bookdone.donation.domain;

import com.bookdone.donation.application.DonationStatus;
import com.bookdone.donation.dto.request.DonationAddRequest;
import com.bookdone.donation.infra.entity.DonationEntity;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Builder
@Getter
public class Donation {
    private Long id;
    private Long isbn;
    private Long memberId;
    private Integer address;
    private String content;
    private DonationStatus status;
    private boolean canDelivery;
    private LocalDateTime createdAt;

    public static Donation createDonation(DonationAddRequest donationAddRequest) {
        return Donation
                .builder()
                .id(donationAddRequest.getId())
                .isbn(donationAddRequest.getIsbn())
                .memberId(donationAddRequest.getMemberId())
                .address(donationAddRequest.getAddress())
                .content(donationAddRequest.getContent())
                .status(DonationStatus.DONATING)
                .canDelivery(donationAddRequest.isCanDelivery())
                .build();
    }

    public static Donation createDonation(DonationEntity donationEntity) {
        return Donation
                .builder()
                .id(donationEntity.getId())
                .isbn(donationEntity.getIsbn())
                .memberId(donationEntity.getMemberId())
                .address(donationEntity.getAddress())
                .content(donationEntity.getContent())
                .status(donationEntity.getStatus())
                .canDelivery(donationEntity.isCanDelivery())
                .createdAt(donationEntity.getCreatedAt())
                .build();
    }

    public DonationEntity createEntity() {
        return DonationEntity.fromDomain(this);
    }

}
